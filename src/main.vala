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

/* main.vala - main function */

using Ev3devKit;
using Ev3devKit.Ui;
using Linux.VirtualTerminal;
using Posix;

namespace BrickManager {
    const string SPLASH_PNG = "splash.png";

    // The global_manager is shared by all of the controller objects
    GlobalManager global_manager;

     public static int main (string[] args) {
        try {
            var app = new ConsoleApp ();

            // Get something up on the screen ASAP.
            var splash_path = Path.build_filename (DATA_DIR, SPLASH_PNG);
            foreach (var dir in Environment.get_system_data_dirs ()) {
                var new_path = Path.build_filename (dir, splash_path);
                if (FileUtils.test (new_path, FileTest.EXISTS)) {
                    splash_path = new_path;
                    break;
                }
            }
            if (!Grx.get_screen_context ().load_from_png (splash_path)) {
                warning ("%s", "Could not load splash image.");
            }

            var activate_id = app.activate.connect (() => {
                app.hold ();

                global_manager = new GlobalManager ();

                Screen.get_active_screen ().status_bar.visible = true;

                var home_window = new HomeWindow ();
                var file_browser_controller = new FileBrowserController ();
                home_window.add_controller (file_browser_controller);
                var device_browser_controller = new DeviceBrowserController ();
                home_window.add_controller (device_browser_controller);
                var network_controller = new NetworkController ();
                home_window.add_controller (network_controller);
                var bluetooth_controller = new BluetoothController ();
                network_controller.add_controller (bluetooth_controller);
                network_controller.add_controller (network_controller.wifi_controller);
                var battery_controller = new BatteryController ();
                home_window.add_controller (battery_controller);
                var open_roberta_controller = new OpenRobertaController ();
                home_window.add_controller (open_roberta_controller);
                var about_controller = new AboutController ();
                home_window.add_controller (about_controller);

                Screen.get_active_screen ().status_bar.add_left (network_controller.network_status_bar_item);

                Screen.get_active_screen ().status_bar.add_right (battery_controller.battery_status_bar_item);
                Screen.get_active_screen ().status_bar.add_right (network_controller.wifi_status_bar_item);
                Screen.get_active_screen ().status_bar.add_right (bluetooth_controller.status_bar_item);
                Screen.get_active_screen ().status_bar.add_right (open_roberta_controller.status_bar_item);

                Systemd.Logind.Manager logind_manager = null;
                Systemd.Logind.Manager.get_system_manager.begin ((obj, res) => {
                    try {
                        logind_manager = Systemd.Logind.Manager.get_system_manager.end (res);
                        home_window.shutdown_dialog.power_off_button_pressed.connect (() => {
                            logind_manager.power_off.begin (false, (obj, res) => {
                                try {
                                    logind_manager.power_off.end (res);
                                    global_manager.set_leds (LedState.BUSY);
                                    app.quit ();
                                } catch (IOError err) {
                                    var dialog = new MessageDialog ("错误", err.message);
                                    dialog.show ();
                                }
                            });
                        });
                        home_window.shutdown_dialog.reboot_button_pressed.connect (() => {
                            logind_manager.reboot.begin (false, (obj, res) => {
                                try {
                                    logind_manager.reboot.end (res);
                                    global_manager.set_leds (LedState.BUSY);
                                    app.quit ();
                                } catch (IOError err) {
                                    var dialog = new MessageDialog ("错误", err.message);
                                    dialog.show ();
                                }
                            });
                        });
                    } catch (IOError err) {
                        var dialog = new MessageDialog ("错误", err.message);
                        dialog.show ();
                    }
                });
                home_window.show ();
                global_manager.set_leds (LedState.NORMAL);
            });

            // FIXME: Need to hook into input events here to get long back press

            app.run ();
            app.disconnect (activate_id);

            return 0;
        } catch (GLib.Error err) {
            critical ("%s", err.message);
            Process.exit (err.code);
        }
    }
}
