#!/bin/bash
# Shows whether the machine is online over Wi-Fi, Ethernet, or not at all.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/icons.sh"

wifi="$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/ { getline; print $2 }')"

if [ -n "$wifi" ] && ipconfig getifaddr "$wifi" >/dev/null 2>&1; then
  icon="$ICON_WIFI"
elif route -n get default >/dev/null 2>&1; then
  icon="$ICON_ETHERNET"
else
  icon="$ICON_WIFI_OFF"
fi

sketchybar --set "$NAME" icon="$icon"
