#!/usr/bin/env bash

# Highlights the focused AeroSpace workspace in SketchyBar
if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.color=0xff7f849c background.drawing=on label.color=0xff11111b icon.color=0xff11111b
else
  sketchybar --set $NAME background.drawing=off label.color=0xffcdd6f4 icon.color=0xffcdd6f4
fi
