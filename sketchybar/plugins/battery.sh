#!/usr/bin/env bash

info=$(pmset -g batt 2>/dev/null)
pct=$(echo "$info" | grep -oE '[0-9]+%' | head -1 | tr -d '%')
charging=$(echo "$info" | grep -o 'charging' | head -1)

if [ -z "$pct" ]; then
  sketchybar --set $NAME icon=$'\uf240' label="AC"
  exit 0
fi

if [ -n "$charging" ]; then
  icon=$'\uf1e6'
elif [ "$pct" -ge 90 ]; then icon=$'\uf240'
elif [ "$pct" -ge 60 ]; then icon=$'\uf241'
elif [ "$pct" -ge 30 ]; then icon=$'\uf242'
elif [ "$pct" -ge 10 ]; then icon=$'\uf243'
else icon=$'\uf244'
fi

sketchybar --set $NAME icon="$icon" label="${pct}%"