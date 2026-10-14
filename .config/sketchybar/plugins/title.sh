#!/bin/bash
# Shows the title of the focused window, or hides the module if there is none.
# AeroSpace has no title-change callback, so this also polls.

title="$(aerospace list-windows --focused --json 2>/dev/null \
  | jq -r '.[0] // empty | if ."window-title" != "" then ."window-title" else ."app-name" end')"

if [ -z "$title" ]; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on label="$title"
fi
