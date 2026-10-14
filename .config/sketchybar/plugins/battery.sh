#!/bin/bash
# Shows the battery level, or a charging icon while plugged in.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/icons.sh"

battery="$(pmset -g batt)"
percent="$(echo "$battery" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"

# Hide the module on machines without a battery.
if [ -z "$percent" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if echo "$battery" | grep -q "AC Power"; then
  icon="$ICON_BATTERY_CHARGING"
elif [ "$percent" -ge 67 ]; then
  icon="$ICON_BATTERY_HIGH"
elif [ "$percent" -ge 34 ]; then
  icon="$ICON_BATTERY_MED"
else
  icon="$ICON_BATTERY_LOW"
fi

sketchybar --set "$NAME" icon="$icon" label="$percent%"
