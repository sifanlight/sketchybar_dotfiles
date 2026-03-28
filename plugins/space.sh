#!/bin/bash

# Extract monitor index from the sketchybar item name (e.g., workspace_current.1)
MONITOR=$(echo "$NAME" | cut -d. -f2)

# Swap monitor IDs if there are exactly 2 monitors, as they appear to be indexed differently
TOTAL_MONITORS=$(sketchybar --query displays | jq '. | length')
if [ "$TOTAL_MONITORS" -eq 2 ]; then
  if [ "$MONITOR" -eq 1 ]; then
    TARGET_MONITOR=2
  else
    TARGET_MONITOR=1
  fi
else
  TARGET_MONITOR=$MONITOR
fi

# Find the workspace currently visible on the target monitor.
FOCUSED=$(/opt/homebrew/bin/aerospace list-workspaces --monitor "$TARGET_MONITOR" --visible | head -n 1)

if [ -n "$FOCUSED" ]; then
    /opt/homebrew/bin/sketchybar --set "$NAME" icon="$FOCUSED"
fi
