#!/bin/bash

focused="$(aerospace list-workspaces --focused 2>/dev/null)"

if [ "$focused" = "5" ]; then
  sketchybar --set "$NAME" label.padding_left=2
else
  sketchybar --set "$NAME" label.padding_left=4
fi