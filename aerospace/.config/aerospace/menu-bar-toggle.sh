#!/usr/bin/env bash

state=$(defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null)
if [ "$state" = "1" ]; then
  defaults write NSGlobalDomain _HIHideMenuBar -bool false
  sketchybar --bar topmost=off y_offset=26
else
  defaults write NSGlobalDomain _HIHideMenuBar -bool true
  sketchybar --bar topmost=on y_offset=0
fi