/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
 *
 * based in part on GNOME Power Manager:
 * Copyright (C) 2008-2011 Richard Hughes <richard@hughsie.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * gui.vala:
 *
 * The main graphical user interface class.
 */

using Gee;
using M2tk;

namespace BrickDisplayManager {

    public class RootInfo {
        public unowned M2tk.Element element;
        public uint8 value;
    }

    class GUI : Object {

        static GUI instance;

        MainLoop main_loop = new MainLoop();
        U8g.Graphics u8g = new U8g.Graphics();
        Deque<RootInfo> root_stack = new LinkedList<RootInfo>();

        Power power = new Power();
        Home home;

        public bool dirty { get; set; default = true; }
        public bool statusbar_visible { get; set; default = true; }
        public U8g.Graphics graphics { get { return u8g; } }

        public GUI() {
            instance = this;
            debug("initializing GUI");
            home = new Home(power);

            u8g.init(U8g.Device.linux_framebuffer);
            init(home.root_element, event_source, event_handler,
                U8gBoxShadowFrameGraphicsHandler);
            set_u8g(u8g, IconType.BOX);
            set_font(FontIndex.F0, U8g.Font.x11_7x13);
            set_font(FontIndex.F1, U8g.Font.m2tk_icon_9);
            set_u8g_additional_text_x_border(3);

            set_root_change_callback((RootChangeFunc)on_root_element_change);
        }

        ~GUI() {
            u8g.stop();
        }

        public void run() {
            var draw_timer = new TimeoutSource(50);
            draw_timer.set_callback(on_draw_timer);
            draw_timer.attach(main_loop.get_context());
            main_loop.run();
        }

        public void quit() {
            main_loop.quit();
        }

        static void on_root_element_change(Element new_root,
            Element old_root, uint8 value)
        {
            if (value != uint8.MAX) {
                var info = new RootInfo();
                info.element = old_root;
                info.value = value;
                instance.root_stack.offer_head(info);
            }
        }

        bool on_draw_timer()
        {
            if (!Curses.isendwin()) {
                check_key();
                instance.dirty |= handle_key();
                if (instance.dirty) {
                   u8g.begin_draw();
                   draw();
                   if (instance.statusbar_visible) {
                      /* M2tk.draw() can change colors on us */
                      instance.u8g.set_default_background_color();
                      instance.u8g.set_default_forground_color();
                      //brickdm_power_draw_battery_status();
                      instance.u8g.draw_line(0, 15, u8g.get_width(), 15);
                 }
                 instance.u8g.end_draw();
                 instance.dirty = false;
             }
          }
          return true;
        }

        static uint8 event_source(M2 m2, EventSourceMessage msg) {
            switch(msg) {
            case EventSourceMessage.GET_KEY:
                switch (Curses.getch()) {
                /* Actual keys on the EV3 */
                case Curses.Key.DOWN:
                    return Key.EVENT | Key.DATA_DOWN;
                case Curses.Key.UP:
                    return Key.EVENT | Key.DATA_UP;
                case Curses.Key.LEFT:
                    return Key.EVENT | Key.PREV;
                case Curses.Key.RIGHT:
                    return Key.EVENT | Key.NEXT;
                case '\n':
                    return Key.EVENT | Key.SELECT;
                case Curses.Key.BACKSPACE:
                    return Key.EVENT | Key.EXIT;

                /* Other keys in case a keyboard or keypad is plugged in */
                case Curses.Key.BTAB:
                case Curses.Key.PREVIOUS:
                    return Key.EVENT | Key.PREV;
                case Curses.Key.NEXT:
                  return Key.EVENT | Key.NEXT;
                case Curses.Key.ENTER:
                case Curses.Key.OPEN:
                   return Key.EVENT | Key.SELECT;
                case Curses.Key.CANCEL:
                case Curses.Key.EXIT:
                    return Key.EVENT | Key.EXIT;
                case Curses.Key.HOME:
                    return Key.EVENT | Key.HOME;
                case Curses.Key.SHOME:
                    return Key.EVENT | Key.HOME2;
                case Curses.Key.F0+1:
                    return Key.EVENT | Key.Q1;
                case Curses.Key.F0+2:
                    return Key.EVENT | Key.Q2;
                case Curses.Key.F0+3:
                    return Key.EVENT | Key.Q3;
                case Curses.Key.F0+4:
                    return Key.EVENT | Key.Q4;
                case Curses.Key.F0+5:
                    return Key.EVENT | Key.Q5;
                case Curses.Key.F0+6:
                    return Key.EVENT | Key.Q6;
                case '0':
                    return Key.EVENT | Key.KEYPAD_0;
                case '1':
                    return Key.EVENT | Key.KEYPAD_1;
                case '2':
                  return Key.EVENT | Key.KEYPAD_2;
                case '3':
                    return Key.EVENT | Key.KEYPAD_3;
                case '4':
                    return Key.EVENT | Key.KEYPAD_4;
                case '5':
                    return Key.EVENT | Key.KEYPAD_5;
                case '6':
                    return Key.EVENT | Key.KEYPAD_6;
                case '7':
                    return Key.EVENT | Key.KEYPAD_7;
                case '8':
                    return Key.EVENT | Key.KEYPAD_8;
                case '9':
                    return Key.EVENT | Key.KEYPAD_9;
                case '*':
                    return Key.EVENT | Key.KEYPAD_STAR;
                case '#':
                    return Key.EVENT | Key.KEYPAD_HASH;
              }
              return Key.NONE;
            case EventSourceMessage.INIT:
                Curses.cbreak();
                Curses.noecho();
                Curses.stdscr.keypad(true);
                Curses.stdscr.nodelay(true);
                break;
            }
            return 0;
        }

        static uint8 event_handler(M2 m2, EventHandlerMessage msg,
            uint8 arg1, uint8 arg2)
        {
            unowned Nav nav = m2.nav;

            switch(msg) {
            case EventHandlerMessage.SELECT:
                return nav.user_down(true);

            case EventHandlerMessage.EXIT:
                // if there is no valid parent, then go to the previous root
                if (nav.user_up() == 0) {
                    var info = instance.root_stack.poll_head();
                    if (info != null) {
                        set_root(info.element, info.value, uint8.MAX);
                    } else {
                        set_root(instance.power.shutdown_root_element);
                    }
                }
                return 1;

            case EventHandlerMessage.NEXT:
                return nav.user_next();

            case EventHandlerMessage.PREV:
                return nav.user_prev();

            case EventHandlerMessage.DATA_DOWN:
                if (nav.data_down() == 0)
                    return nav.user_next();
                return 1;

            case EventHandlerMessage.DATA_UP:
                if (nav.data_up() == 0)
                    return nav.user_prev();
                return 1;
            }

            if (msg >= Key.Q1 && msg <= Key.LOOP_END) {
                if (nav.quick_key((Key)msg - Key.Q1 + 1) != 0)
                {
                    if (nav.is_data_entry)
                        return nav.data_up();
                    return nav.user_down(true);
                }
            }

            if (msg >= ElementCallbackMessage.SPACE) {
                nav.data_char(msg);      // assign the char
                return nav.user_next();  // go to next position
            }
            return 0;
        }
    }
}