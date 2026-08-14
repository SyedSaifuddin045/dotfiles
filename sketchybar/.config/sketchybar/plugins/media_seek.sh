#!/usr/bin/env bash

dur=$(nowplaying-cli get duration 2>/dev/null)
if [ "$dur" = "null" ] || [ -z "$dur" ] || [ "$dur" = "0" ]; then
  exit 0
fi
sec=$(awk -v p="$PERCENTAGE" -v du="$dur" 'BEGIN{ printf "%d", p * du / 100 }')
nowplaying-cli seek "$sec"