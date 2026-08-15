#!/usr/bin/env bash

pct=$(python3 "$(dirname "$0")/media_progress.py")
sketchybar --set $NAME slider.percentage=$pct