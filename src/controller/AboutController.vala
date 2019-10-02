/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* AboutController.vala - Controller for about window */

using Ev3devKit.Devices;
using Ev3devKit.Ui;

namespace BrickManager {
    public class AboutController : Object, IBrickManagerModule {
        AboutWindow about_window;

        public string display_name { get { return "关于"; } }

        public void show_main_window () {
            if (about_window == null) {
                create_about_window ();
            }
            about_window.show ();
        }

        void create_about_window () {
            about_window = new AboutWindow (display_name);
            var utsname = Posix.UTSName ();
            if (Posix.uname (ref utsname) == 0) {
                about_window.kernel_version = utsname.release;
            } else {
                warning ("Failed to get kernel version.");
            }
            about_window.model_name = Cpu.get_model ();
            about_window.revision = Cpu.get_revision ();
            about_window.serial_number = Cpu.get_serial_number ();
        }
    }
}
