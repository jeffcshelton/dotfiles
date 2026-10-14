#!/bin/bash
# Shows total CPU usage across all cores.

cores="$(sysctl -n hw.ncpu)"
usage="$(ps -A -o %cpu= | awk -v cores="$cores" '{ sum += $1 } END { printf "%d", sum / cores }')"

sketchybar --set "$NAME" label="$usage%"
