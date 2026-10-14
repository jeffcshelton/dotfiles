#!/bin/bash
# Shows the percentage of memory in use, as reported by the kernel.

free="$(memory_pressure | awk '/free percentage/ { sub("%", "", $5); print $5 }')"

sketchybar --set "$NAME" label="$((100 - free))%"
