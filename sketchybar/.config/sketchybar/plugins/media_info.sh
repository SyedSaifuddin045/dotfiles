#!/usr/bin/env bash

client=$(nowplaying-cli get-raw 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print(''); sys.exit()
print(d.get('kMRMediaRemoteNowPlayingInfoClientBundleIdentifier') or '')
")

label=""
if [ "$client" = "com.spotify.client" ]; then
  label=$(osascript -e 'tell application "Spotify"' -e 'set t to name of current track' -e 'set a to artist of current track' -e 'set pos to player position' -e 'set dur to duration of current track' -e 'return a & "|" & t & "|" & pos & "|" & dur' -e 'end tell' 2>/dev/null)
fi

if [ -n "$label" ]; then
  artist="${label%%|*}"
  rest="${label#*|}"
  title="${rest%%|*}"
  rest2="${rest#*|}"
  pos="${rest2%%|*}"
  dur="${rest2#*|}"
  dur=$(awk -v d="$dur" 'BEGIN{ printf "%.2f", d/1000 }')
  if [ -n "$title" ] && [ "$title" != "null" ]; then
    out="$title"
    [ -n "$artist" ] && [ "$artist" != "null" ] && out="$artist — $out"
    if [ "$dur" != "0" ] && [ -n "$dur" ]; then
      out=$(awk -v l="$out" -v p="$pos" -v d="$dur" 'BEGIN{
        if (p<0) p=0; if (p>d) p=d
        e=int(p); dd=int(d)
        printf "%s · %d:%02d/%d:%02d", l, e/60, e%60, dd/60, dd%60
      }')
    fi
    sketchybar --set $NAME label="$out"
    exit 0
  fi
fi

title=$(nowplaying-cli get title 2>/dev/null)
artist=$(nowplaying-cli get artist 2>/dev/null)

if [ -z "$title" ] || [ "$title" = "null" ]; then
  sketchybar --set $NAME label=""
else
  if [ -n "$artist" ] && [ "$artist" != "null" ]; then
    sketchybar --set $NAME label="$artist — $title"
  else
    sketchybar --set $NAME label="$title"
  fi
fi