#!/bin/bash
# Shows whether Bluetooth is on and how many devices are connected.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/icons.sh"

data="$(system_profiler SPBluetoothDataType -json 2>/dev/null)"
state="$(echo "$data" | jq -r '.SPBluetoothDataType[0].controller_properties.controller_state')"
connected="$(echo "$data" | jq '.SPBluetoothDataType[0].device_connected // [] | length')"

if [ "$state" != "attrib_on" ]; then
  sketchybar --set "$NAME" icon="$ICON_BLUETOOTH_OFF" label.drawing=off icon.padding_right=10
elif [ "$connected" -gt 0 ]; then
  sketchybar --set "$NAME" icon="$ICON_BLUETOOTH" label="$connected" label.drawing=on icon.padding_right=6
else
  sketchybar --set "$NAME" icon="$ICON_BLUETOOTH" label="on" label.drawing=on icon.padding_right=6
fi
