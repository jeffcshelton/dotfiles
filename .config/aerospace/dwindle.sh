#!/bin/bash
# Emulates Hyprland's dwindle layout. AeroSpace inserts a new window right
# after the focused one, so joining the new window with that neighbor nests
# the pair in a container of the opposite orientation, splitting the window
# that was focused. Runs on every focus change and treats windows it hasn't
# seen before as new.

seen="${TMPDIR:-/tmp}/aerospace-dwindle-seen"

read -r id layout < <(aerospace list-windows --focused \
  --format '%{window-id} %{window-parent-container-layout}' 2>/dev/null)
[ -n "$id" ] || exit 0

# On the first run after AeroSpace starts, every window already exists.
if [ ! -f "$seen" ]; then
  aerospace list-windows --all --format '%{window-id}' > "$seen"
  exit 0
fi

grep -qx "$id" "$seen" && exit 0
echo "$id" >> "$seen"

# The first two windows on a workspace simply sit side by side.
tiled="$(aerospace list-windows --workspace focused \
  --format '%{window-parent-container-layout}' | grep -c '_tiles$')"
[ "$tiled" -ge 3 ] || exit 0

case "$layout" in
  h_tiles) aerospace join-with left ;;
  v_tiles) aerospace join-with up ;;
esac
