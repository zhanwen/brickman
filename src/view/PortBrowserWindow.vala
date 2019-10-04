/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2015 David Lechner <david@lechnology.com>
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
 * PortBrowserWindow.vala: Main Device Browser Menu
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class PortBrowserWindow : BrickManagerWindow {
        internal Ui.Menu menu;

        public PortBrowserWindow () {
            title ="端口";
            menu = new Ui.Menu () {
                margin_top = -3
            };
            content_vbox.add (menu);
        }
    }
}
