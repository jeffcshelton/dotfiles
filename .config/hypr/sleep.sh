#!/bin/env sh

# Turn off external display.
hyprctl dispatch dpms off

# Turn off RGB lighting.
if command -v openrgb; then
  openrgb --mode off
fi
