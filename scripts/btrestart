#!/bin/bash
bluetoothctl power off
sudo systemctl stop bluetooth
sudo rfkill block bluetooth
sudo rfkill unblock bluetooth
sudo systemctl start bluetooth
sleep 1
bluetoothctl power on
exit 0
