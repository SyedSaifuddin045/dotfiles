#!/usr/bin/env bash

usage=$(top -l 2 -s 1 | grep '^CPU usage' | tail -1 | grep -oE '[0-9.]+%' | awk '{p=$1+0; total+=p; last=p} END{printf "%d", total-last}')
sketchybar --set $NAME icon="󰍛" label="${usage}%"