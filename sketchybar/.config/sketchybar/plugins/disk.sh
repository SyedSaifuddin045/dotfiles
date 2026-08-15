#!/usr/bin/env bash

used_pct=$(df -h /System/Volumes/Data 2>/dev/null | awk 'NR==2 {print $5}')

sketchybar --set "$NAME" icon=$'\ueb50' label="${used_pct}"
