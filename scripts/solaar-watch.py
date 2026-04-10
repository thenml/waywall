## Copyright (C) 2012-2013  Daniel Pavel
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License along
## with this program; if not, write to the Free Software Foundation, Inc.,
## 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

import yaml
import time
import os
import sys

from logitech_receiver import settings
from logitech_receiver import settings_templates
from logitech_receiver.common import NamedInts
from logitech_receiver.settings_templates import SettingsProtocol

from solaar import configuration
from solaar.cli.__init__ import _cli_parser, _receivers_and_devices, _find_receiver, _find_device
from solaar.cli.config import *

APP_ID = "io.github.pwr_solaar.solaar"


def watch_set(dev, setting, filepath="/tmp/solaar-watch-set", interval=0.05, save=True):
    """
    Watch a file for a value and set the device setting whenever it changes.
    """
    last_value = None
    while True:
        try:
            if os.path.exists(filepath):
                with open(filepath, "r") as f:
                    value = f.read().strip()
                if value != last_value:
                    args = type('Args', (object,), {})()
                    args.device = dev.name
                    args.setting = setting.name
                    args.value_key = value
                    args.extra_subkey = None
                    args.extra2 = None
                    _, message, _ = set(dev, setting, args, save)
                    print(message)
                    last_value = value
        except Exception as e:
            print("Error:", e)
        time.sleep(interval)


def run_watch(receivers, args, _find_receiver, find_device):
    assert receivers
    assert args.device

    device_name = args.device.lower()

    dev = None
    for dev in find_device(receivers, device_name):
        if dev.ping():
            break
        dev = None

    if not dev:
        raise Exception(f"no online device found matching '{device_name}'")

    if not args.setting:
        if not dev.settings:
            raise Exception(f"no settings for {dev.name}")
        configuration.attach_to(dev)
        print(dev.name, f"({dev.codename}) [{dev.wpid}:{dev.serial}]")
        for s in dev.settings:
            print("")
            _print_setting(s)
        return

    setting_name = args.setting.lower()
    setting = settings_templates.check_feature_setting(dev, setting_name)
    if not setting and dev.descriptor and dev.descriptor.settings:
        for sclass in dev.descriptor.settings:
            if sclass.register and sclass.name == setting_name:
                try:
                    setting = sclass.build(dev)
                except Exception:
                    setting = None
    if setting is None:
        raise Exception(f"no setting '{args.setting}' for {dev.name}")

    print(f"Watching /tmp/solaar-watch-set for changes to set {setting.name} on {dev.name}")
    watch_set(dev, setting)

cli_args = sys.argv[1:]
cli_args.insert(0, "config")
args = _cli_parser.parse_args(cli_args)
c = list(_receivers_and_devices(None))
if not c:
    raise Exception(
        'No supported device found. Use "lsusb" and "bluetoothctl devices Connected" to list connected devices.'
    )
run_watch(c, args, _find_receiver, _find_device)