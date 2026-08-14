#!/usr/bin/env bash

pct=$(pmset -g batt | grep -oE '[0-9]+%' | head -1)
if [ -z "$pct" ]; then
  sketchybar --set $NAME icon="" label="AC"
else
  sketchybar --set $NAME icon="" label="$pct"
fi