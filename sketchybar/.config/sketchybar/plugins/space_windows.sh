#!/usr/bin/env bash

# Refreshes the app-icon preview strip on every workspace.
# Shows which apps are currently open in each workspace.
# Populated spaces get a right margin; empty spaces center their number.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

for ws in 1 2 3 4 5; do
  apps=$(aerospace list-windows --workspace "$ws" --format '%{app-name}' 2>/dev/null)
  strip=""
  if [ -n "$apps" ]; then
    while read -r app; do
      [ -n "$app" ] && strip+=" $("$CONFIG_DIR/helpers/icon_map.sh" "$app")"
    done <<<"$apps"
    sketchybar --set "space.$ws" label="$strip" label.padding_left=4 label.padding_right=8
  else
    sketchybar --set "space.$ws" label="" label.padding_left=0 label.padding_right=0
  fi
  "$CONFIG_DIR/helpers/workspace_style.sh" "$ws"
done
