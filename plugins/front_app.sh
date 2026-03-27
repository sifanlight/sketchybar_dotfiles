#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  # Get the icon using the mapping script
  icon=$("$CONFIG_DIR/plugins/icon_map.sh" "$INFO")

  sketchybar --set "$NAME" \
             icon="$icon" \
             icon.font="sketchybar-app-font:Regular:16.0" \
             label="$INFO"
elif [ "$SENDER" = "display_change" ]; then
  sketchybar --reload
fi
