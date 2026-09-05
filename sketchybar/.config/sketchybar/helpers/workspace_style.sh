#!/usr/bin/env bash

# Sets complete visual state for one workspace item based on focus + window
# count. Idempotent: callers may invoke it any time, in any order.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

ws="$1"
focused=$(aerospace list-workspaces --focused 2>/dev/null)

count=0
app_names=$(aerospace list-windows --workspace "$ws" --format '%{app-name}' 2>/dev/null)
[ -n "$app_names" ] && count=$(printf '%s\n' "$app_names" | wc -l | tr -d ' ')

if [ "$ws" = "$focused" ]; then
  sketchybar --set "space.$ws" \
    background.color=0xff89b4fa \
    background.drawing=on \
    background.border_width=0 \
    icon.color=0xff11111b \
    label.color=0xff11111b
elif [ "$count" -gt 0 ]; then
  sketchybar --set "space.$ws" \
    background.color=0x00000000 \
    background.drawing=on \
    background.border_color=0x6689b4fa \
    background.border_width=2 \
    icon.color=0xffcdd6f4 \
    label.color=0xffcdd6f4
else
  sketchybar --set "space.$ws" \
    background.drawing=on \
    background.color=0x00000000 \
    background.border_color=0x6689b4fa \
    background.border_width=2 \
    icon.color=0xffcdd6f4 \
    label.color=0xffcdd6f4
fi