/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2014-2015 David Lechner <david@lechnology.com>
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
 * BluetoothWindow.vala: Main Bluetooth Menu
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class BluetoothWindow : BrickManagerWindow {
        Ui.Menu powered_menu;
        Ui.Menu unpowered_menu;
        CheckboxMenuItem powered_menu_item;
        CheckboxMenuItem visible_menu_item;
        Ui.MenuItem scan_menu_item;

        bool _powered;
        public bool powered {
            get { return _powered; }
            set {
                if (value == _powered)
                    return;
                _powered = value;
                powered_menu_item.checkbox.checked = value;
                if (value) {
                    content_vbox.remove (unpowered_menu);
                    content_vbox.add (powered_menu);
                    powered_menu.insert_menu_item (powered_menu_item, visible_menu_item);
                } else {
                    content_vbox.remove (powered_menu);
                    content_vbox.add (unpowered_menu);
                    unpowered_menu.add_menu_item (powered_menu_item);
                }
            }
        }

        public bool bt_visible {
            get { return visible_menu_item.checkbox.checked; }
            set { visible_menu_item.checkbox.checked = value; }
        }

        bool _scanning;
        public bool scanning {
            get { return _scanning; }
            set {
                _scanning = value;
                scan_menu_item.label.text = value ? "停止扫描" : "开始扫描";
            }
        }

        public signal void scan_selected ();

        public BluetoothWindow (string display_name) {
            title = display_name;
            content_vbox.spacing = 0;
            powered_menu_item = new CheckboxMenuItem ("开关");
            powered_menu_item.button.vertical_align = WidgetAlign.START;
            weak Ui.MenuItem weak_powered_menu_item = powered_menu_item;
            powered_menu_item.button.pressed.connect (() => {
                powered = !powered;
                weak_powered_menu_item.button.focus ();
            });
            content_vbox.add (powered_menu_item.button);
            powered_menu = new Ui.Menu ();
            visible_menu_item = new CheckboxMenuItem ("可见");
            visible_menu_item.checkbox.notify["checked"].connect (() =>
                notify_property ("bt-visible"));
            powered_menu.add_menu_item (visible_menu_item);
            scan_menu_item = new Ui.MenuItem ("???");
            scan_menu_item.button.pressed.connect (() => scan_selected ());
            powered_menu.add_menu_item (scan_menu_item);
            var devices_label_menu_item = new Ui.MenuItem ("设备");
            devices_label_menu_item.label.horizontal_align = WidgetAlign.CENTER;
            devices_label_menu_item.button.border_bottom = 1;
            devices_label_menu_item.button.margin_bottom = 2;
            devices_label_menu_item.button.can_focus = false;
            powered_menu.add_menu_item (devices_label_menu_item);
            unpowered_menu = new Ui.Menu ();
        }

        public void add_menu_item (Ui.MenuItem menu_item) {
            powered_menu.add_menu_item (menu_item);
        }

        public void remove_menu_item (Ui.MenuItem menu_item) {
            powered_menu.remove_menu_item (menu_item);
        }

        public Ui.MenuItem? find_menu_item (Object represented_object) {
            return powered_menu.find_menu_item<Object> (represented_object, (mi, o) =>
                o == mi.represented_object);
        }
    }
}
