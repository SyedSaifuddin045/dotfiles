#!/usr/bin/env bash

# Shows the icon + name of the currently focused app.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

if [ -z "$INFO" ] || [ "$INFO" = "null" ]; then
  app=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)
else
  app="$INFO"
fi

[ -z "$app" ] && app="Finder"

icon=$("$CONFIG_DIR/helpers/icon_map.sh" "$app")
sketchybar --set $NAME icon="$icon" label="$app"
