#!/bin/bash
# Shows workspaces that have windows or are visible on a monitor, highlighting
# the visible ones, the same way Waybar's Hyprland workspaces module does.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

# Leave the bar alone if AeroSpace isn't running.
visible="$(aerospace list-workspaces --monitor all --visible 2>/dev/null)" || exit 0
occupied="$(aerospace list-workspaces --monitor all --empty no)"

args=()
for space in 1 2 3 4 5 6 7 8 9 10; do
  if echo "$visible" | grep -qx "$space"; then
    args+=(--set "space.$space" drawing=on icon.color=$TEXT)
  elif echo "$occupied" | grep -qx "$space"; then
    args+=(--set "space.$space" drawing=on icon.color=$HIGHLIGHT_MED)
  else
    args+=(--set "space.$space" drawing=off)
  fi
done

sketchybar "${args[@]}"
