#!/bin/bash
# Shows the output volume. Scrolling over the module adjusts it.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/icons.sh"

if [ "$SENDER" = "mouse.scrolled" ]; then
  # The resulting volume_change event updates the module.
  osascript -e "set volume output volume (output volume of (get volume settings) + $SCROLL_DELTA)"
  exit 0
fi

if [ "$SENDER" = "volume_change" ]; then
  volume="$INFO"
else
  volume="$(osascript -e 'output volume of (get volume settings)')"
fi

if [ "$(osascript -e 'output muted of (get volume settings)')" = true ]; then
  sketchybar --set "$NAME" icon="$ICON_VOLUME_MUTED" label.drawing=off icon.padding_right=10
  exit 0
fi

if [ "$volume" -ge 66 ]; then
  icon="$ICON_VOLUME_HIGH"
elif [ "$volume" -ge 33 ]; then
  icon="$ICON_VOLUME_MED"
else
  icon="$ICON_VOLUME_LOW"
fi

sketchybar --set "$NAME" icon="$icon" label="$volume" label.drawing=on icon.padding_right=6
