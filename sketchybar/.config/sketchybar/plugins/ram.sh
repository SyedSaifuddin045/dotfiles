#!/usr/bin/env bash

page_size=$(vm_stat | grep -oE 'page size of [0-9]+ bytes' | grep -oE '[0-9]+')
total_bytes=$(sysctl -n hw.memsize)
total_pages=$((total_bytes / page_size))

active=$(vm_stat | awk '/^Pages active:/{v=$NF; gsub(/\./,"",v); print v}')
wired=$(vm_stat | awk '/^Pages wired down:/{v=$NF; gsub(/\./,"",v); print v}')
comp=$(vm_stat | awk '/^Pages occupied by compressor:/{v=$NF; gsub(/\./,"",v); print v}')
spec=$(vm_stat | awk '/^Pages speculative:/{v=$NF; gsub(/\./,"",v); print v}')

if [ -z "$active" ] || [ -z "$wired" ] || [ -z "$comp" ] || [ -z "$spec" ] || [ "$total_pages" -eq 0 ]; then
  sketchybar --set $NAME icon="" label="?%"
  exit 0
fi

used_pages=$((active + wired + comp + spec))
used_pct=$((used_pages * 100 / total_pages))
sketchybar --set $NAME icon="" label="${used_pct}%"