#!/bin/bash

# Extract monitor index from the sketchybar item name (e.g., workspace_current.1)
MONITOR=$(echo "$NAME" | cut -d. -f2)

# Find the workspace currently visible on the specific monitor.
FOCUSED=$(/opt/homebrew/bin/aerospace list-workspaces --monitor "$MONITOR" --visible | head -n 1)

if [ -n "$FOCUSED" ]; then
    /opt/homebrew/bin/sketchybar --set "$NAME" icon="$FOCUSED"
fi
