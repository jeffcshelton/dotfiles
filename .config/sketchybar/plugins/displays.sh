#!/bin/bash
# Shows the window title only on external displays, since the notch on the
# built-in display would cover the center of the bar.

externals=""
while read -r arrangement id; do
  builtin="$(osascript -l JavaScript -e "ObjC.import('CoreGraphics'); \$.CGDisplayIsBuiltin($id)")"
  if [ "$builtin" != 1 ]; then
    externals="${externals:+$externals,}$arrangement"
  fi
done < <(sketchybar --query displays | jq -r '.[] | "\(."arrangement-id") \(.DirectDisplayID)"')

if [ -z "$externals" ]; then
  sketchybar --set title drawing=off updates=off
else
  sketchybar --set title display="$externals" updates=on \
    --update
fi
