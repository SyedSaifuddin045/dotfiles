#!/usr/bin/env bash

info=$(pmset -g batt 2>/dev/null)
pct=$(echo "$info" | grep -oE '[0-9]+%' | head -1 | tr -d '%')
charging=$(echo "$info" | grep -oE 'charging|discharging' | head -1)

if [ -z "$pct" ]; then
  sketchybar --set "$NAME" icon="" label="AC"
  exit 0
fi

if [ "$charging" = "charging" ]; then
  icon="󰂄"
elif [ "$pct" -ge 100 ]; then icon="󰁹"
elif [ "$pct" -ge 90 ]; then icon="󰂂"
elif [ "$pct" -ge 80 ]; then icon="󰂁"
elif [ "$pct" -ge 70 ]; then icon="󰂀"
elif [ "$pct" -ge 60 ]; then icon="󰁿"
elif [ "$pct" -ge 50 ]; then icon="󰁾"
elif [ "$pct" -ge 40 ]; then icon="󰁽"
elif [ "$pct" -ge 30 ]; then icon="󰁼"
elif [ "$pct" -ge 20 ]; then icon="󰁻"
elif [ "$pct" -ge 10 ]; then icon="󰁺"
elif [ "$pct" -ge 0 ]; then icon="󰂎"
else icon=$'\uf244'
fi

sketchybar --set "$NAME" icon="$icon" label="${pct}%"