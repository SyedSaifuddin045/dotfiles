#!/usr/bin/env bash

app=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)
title=$(aerospace list-windows --focused --format '%{window-title}' 2>/dev/null)

if [ -z "$app" ]; then
  sketchybar --set $NAME label=""
else
  sketchybar --set $NAME label="$app: $title"
fi