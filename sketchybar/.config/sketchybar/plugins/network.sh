#!/usr/bin/env bash

STATE="/tmp/sb_net_state"

# Cumulative rx/tx bytes across all interfaces (link rows), no sudo needed
read -r rx_now tx_now <<< "$(netstat -ib | awk '/<Link#/ {rx+=$7; tx+=$10} END {print rx+0, tx+0}')"
now=$(date +%s)

down=0
up=0
if [ -f "$STATE" ]; then
  read -r prev_rx prev_tx prev_ts < "$STATE"
  dt=$((now - prev_ts))
  # skip stale samples (e.g. after sleep/restart) and negative counter resets
  if [ "$dt" -gt 0 ] && [ "$dt" -le 60 ]; then
    down=$(( (rx_now - prev_rx) / dt ))
    up=$(( (tx_now - prev_tx) / dt ))
    [ "$down" -lt 0 ] && down=0
    [ "$up" -lt 0 ] && up=0
  fi
fi
echo "$rx_now $tx_now $now" > "$STATE"

fmt() {
  local b=$1 v unit="B/s"
  if [ "$b" -ge 1073741824 ]; then v=$((b / 1073741824)); unit="GB/s"
  elif [ "$b" -ge 1048576 ]; then v=$((b / 1048576)); unit="MB/s"
  elif [ "$b" -ge 1024 ]; then v=$((b / 1024)); unit="KB/s"
  else v=$b
  fi
  printf '%s%s' "$v" "$unit"
}

down_s=$(fmt "$down")
up_s=$(fmt "$up")

sketchybar --set "$NAME" icon="" label=" ${down_s}   ${up_s}"
