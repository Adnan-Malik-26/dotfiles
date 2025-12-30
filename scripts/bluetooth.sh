#!/usr/bin/env bash

BT_POWER_STATE=$(bluetoothctl show | grep "Powered" | awk '{print $2}')
DEVICES=$(bluetoothctl devices | awk '{print $2 " " $3}')

menu() {
  echo "󰂯  Toggle Bluetooth ($BT_POWER_STATE)"
  echo "  Scan"
  echo "󰋋  Devices"
  echo "󰈆  Exit"
}

device_menu() {
  bluetoothctl devices | while read -r line; do
    MAC=$(echo "$line" | awk '{print $2}')
    NAME=$(echo "$line" | cut -d ' ' -f3-)
    STATUS=$(bluetoothctl info "$MAC" | grep "Connected" | awk '{print $2}')
    echo "$NAME | $MAC | $STATUS"
  done
}

case "$(menu | rofi -dmenu -p "Bluetooth" -theme $HOME/.config/rofi/bluetooth.rasi)" in
"Toggle Bluetooth ($BT_POWER_STATE)")
  if [ "$BT_POWER_STATE" = "yes" ]; then
    bluetoothctl power off
  else
    bluetoothctl power on
  fi
  ;;

"Scan")
  bluetoothctl scan on &
  sleep 5
  bluetoothctl scan off
  ;;

"Devices")
  SELECT=$(device_menu | rofi -dmenu -p "Select Device")
  MAC=$(echo "$SELECT" | awk -F '|' '{print $2}' | tr -d ' ')
  STATUS=$(echo "$SELECT" | awk -F '|' '{print $3}' | tr -d ' ')

  if [ "$STATUS" = "yes" ]; then
    bluetoothctl disconnect "$MAC"
  else
    bluetoothctl connect "$MAC"
  fi
  ;;

*)
  exit 0
  ;;
esac
