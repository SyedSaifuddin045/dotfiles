#!/usr/bin/env bash

# Highlights the focused AeroSpace workspace in SketchyBar.
# All styling is owned by the shared workspace_style helper.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

exec "$CONFIG_DIR/helpers/workspace_style.sh" "$1"