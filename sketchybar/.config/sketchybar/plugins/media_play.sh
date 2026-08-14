#!/usr/bin/env bash

client=$(nowplaying-cli get-raw 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print(''); sys.exit()
print(d.get('kMRMediaRemoteNowPlayingInfoClientBundleIdentifier') or '')
")

state=""
if [ "$client" = "com.spotify.client" ]; then
  state=$(osascript -e 'tell application "Spotify" to player state' 2>/dev/null)
fi

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