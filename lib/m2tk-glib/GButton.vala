/*
 * m2tk-glib -- GLib bindings for m2tklib graphical toolkit
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
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
 * GButton.vala:
 *
 * wrapper for m2tk BUTTON
 */


namespace M2tk {
    public class GButton : M2tk.GElement {
        Button button { get { return (Button)element; } }

        string _text;
        public string text {
            get { return _text; }
            set {
                _text = value;
                button.text = _text;
                // TODO: set dirty
            }
        }

        public FontSpec font {
            get { return _font; }
            set {
                _font = value;
                update_format();
            }
        }

        public bool? read_only {
            get { return _read_only; }
            set {
                _read_only = value;
                update_format();
            }
        }

        public uint8? x {
            get { return _x; }
            set {
                _x = value;
                update_format();
            }
        }

        public uint8? y {
            get { return _y; }
            set {
                _y = value;
                update_format();
            }
        }

        public uint8? width {
            get { return _width; }
            set {
                _width = value;
                update_format();
            }
        }

        public uint8? height {
            get { return _height; }
            set {
                _height = value;
                update_format();
            }
        }

        public signal void pressed();

        public GButton(string text) {
            element = Button.create((ButtonFunc)on_button, text);
            base(element);
            this._text = text;
        }

        static void on_button(ElementFuncArgs arg) {
            ((GButton)element_map[arg.element]).pressed();
        }
    }
}