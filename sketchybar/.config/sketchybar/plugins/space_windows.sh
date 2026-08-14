#!/usr/bin/env bash

# Refreshes the app-icon preview strip on every workspace.
# Shows which apps are currently open in each workspace.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

for ws in $(aerospace list-workspaces --all --format '%{workspace}' 2>/dev/null); do
  apps=$(aerospace list-windows --workspace "$ws" --format '%{app-name}' 2>/dev/null)
  strip=""
  if [ -n "$apps" ]; then
    while read -r app; do
      [ -n "$app" ] && strip+=" $("$CONFIG_DIR/helpers/icon_map.sh" "$app")"
    done <<<"$apps"
  fi
  sketchybar --set "space.$ws" label="$strip"
done
