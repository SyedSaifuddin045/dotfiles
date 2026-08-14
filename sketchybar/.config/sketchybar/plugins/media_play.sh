#!/usr/bin/env bash

client=$(nowplaying-cli get-raw 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print(''); sys.exit()
print(d.get('kMRMediaRemoteNowPlayingInfoClientBundleIdentifier') or '')
")

present=""
state=""

if [ "$client" = "com.spotify.client" ]; then
  state=$(osascript -e 'tell application "Spotify" to player state' 2>/dev/null)
  if [ "$state" = "playing" ] || [ "$state" = "paused" ]; then
    present=1
  fi
else
  title=$(nowplaying-cli get title 2>/dev/null)
  if [ -n "$title" ] && [ "$title" != "null" ]; then
    present=1
  fi
fi

# Debounce: only flip drawing after presence is stable for N consecutive ticks.
# Prevents flicker when nowplaying-cli/Spotify presence is unstable at play start.
STATE=/tmp/sb_media_present
COUNT=/tmp/sb_media_count
ON_THRESHOLD=3
OFF_THRESHOLD=2

displayed=$(cat "$STATE" 2>/dev/null); displayed=${displayed:-0}
count=$(cat "$COUNT" 2>/dev/null); count=${count:-0}
want=0
[ -n "$present" ] && want=1

if [ "$want" = "$displayed" ]; then
  count=0
else
  count=$((count + 1))
  need=$ON_THRESHOLD
  [ "$want" = 0 ] && need=$OFF_THRESHOLD
  if [ "$count" -ge "$need" ]; then
    displayed=$want
    count=0
    if [ "$displayed" = 1 ]; then
      sketchybar --set media_progress drawing=on \
                 --set media_info drawing=on \
                 --set media_next drawing=on \
                 --set media_play drawing=on \
                 --set media_prev drawing=on
    else
      sketchybar --set media_progress drawing=off \
                 --set media_info drawing=off \
                 --set media_next drawing=off \
                 --set media_play drawing=off \
                 --set media_prev drawing=off
    fi
    echo "$displayed" > "$STATE"
  fi
fi
echo "$count" > "$COUNT"

if [ -z "$state" ]; then
  state=$(nowplaying-cli get-raw 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print('paused'); sys.exit()
r = d.get('kMRMediaRemoteNowPlayingInfoPlaybackRate') or 0
print('playing' if r > 0 else 'paused')
")
fi

if [ "$state" = "playing" ]; then
  sketchybar --set $NAME icon=""
else
  sketchybar --set $NAME icon=""
fi