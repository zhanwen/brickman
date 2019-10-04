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
 * BatteryInfoWindow.vala - displays infomation about the battery
 */

using Ev3devKit.Ui;

namespace BrickManager {
    public class BatteryInfoWindow : BrickManagerWindow {
        const string UNKNOWN_VALUE = "???";

        Grid info_grid;
        Label tech_label;
        Label tech_value_label;
        Label voltage_label;
        Label voltage_value_label;
        Label current_label;
        Label current_value_label;
        Label power_label;
        Label power_value_label;

        public string technology {
            get { return tech_value_label.text; }
            set { tech_value_label.text = value; }
        }

        public bool has_voltage {
            get { return voltage_label.visible; }
            set {
                voltage_label.visible = value;
                voltage_value_label.visible = value;
            }
        }

        double _voltage;
        public double voltage {
            get { return _voltage; }
            set {
                _voltage = value;
                voltage_value_label.text = "%.2fV".printf (value);
            }
        }

        public bool has_current {
            get { return current_label.visible; }
            set {
                current_label.visible = value;
                current_value_label.visible = value;
            }
        }

        double _current;
        public double current {
            get { return _current; }
            set {
                _current = value;
                current_value_label.text = "%.0fmA".printf (value);
            }
        }

        public bool has_power {
            get { return power_label.visible; }
            set {
                power_label.visible = value;
                power_value_label.visible = value;
            }
        }

        double _power;
        public double power {
            get { return _power; }
            set {
                _power = value;
                power_value_label.text = "%.2fW".printf (value);
            }
        }

        public BatteryInfoWindow (string display_name) {
            title = display_name;
            info_grid = new Grid (4, 2);
            content_vbox.add (info_grid);
            tech_label = new Label ("类型:") {
                horizontal_align = WidgetAlign.END,
                padding = 2
            };
            tech_value_label = new Label (UNKNOWN_VALUE) {
                horizontal_align = WidgetAlign.START,
                padding = 2
            };
            voltage_label = new Label ("电压:") {
                horizontal_align = WidgetAlign.END,
                padding = 2
            };
            voltage_value_label = new Label (UNKNOWN_VALUE) {
                horizontal_align = WidgetAlign.START,
                padding = 2
            };
            current_label = new Label ("当前:") {
                horizontal_align = WidgetAlign.END,
                padding = 2
            };
            current_value_label = new Label (UNKNOWN_VALUE) {
                horizontal_align = WidgetAlign.START,
                padding = 2
            };
            power_label = new Label ("电源:") {
                horizontal_align = WidgetAlign.END,
                padding = 2
            };
            power_value_label = new Label (UNKNOWN_VALUE) {
                horizontal_align = WidgetAlign.START,
                padding = 2
            };
            info_grid.add (tech_label);
            info_grid.add (tech_value_label);
            info_grid.add (voltage_label);
            info_grid.add (voltage_value_label);
            info_grid.add (current_label);
            info_grid.add (current_value_label);
            info_grid.add (power_label);
            info_grid.add (power_value_label);
            content_vbox.add (new Spacer ());
        }
    }
}
