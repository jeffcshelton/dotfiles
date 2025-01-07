#!/bin/env sh

# Turn external display back on.
hyprctl dpms dispatch on

# Turn back on the RGB lighting.
if command -v openrgb; then
  openrgb --mode rainbow
fi
