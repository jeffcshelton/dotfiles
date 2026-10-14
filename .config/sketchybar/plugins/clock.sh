#!/bin/bash
# Shows the time in 12-hour format.

sketchybar --set "$NAME" label="$(date '+%I:%M %p')"
