#!/bin/bash

# Required font: sketchybar-app-font
# Required tools: aerospace, lsappinfo, jq

# Get the current list of running apps from AeroSpace
current_apps=$(aerospace list-windows --all --format "%{app-name}" | sort -u)

# Get the list of app items currently in Sketchybar, sorted
# We use jq to parse the JSON output from sketchybar --query bar
existing_app_items=$(sketchybar --query bar | jq -r '.items[] | select(test("^app\\.")) | sub("^app\\."; "")' | sort -u)

# Identify apps to add and remove
apps_to_add=$(comm -23 <(echo "$current_apps") <(echo "$existing_app_items"))
apps_to_remove=$(comm -13 <(echo "$current_apps") <(echo "$existing_app_items"))

args=()

# Remove apps that are no longer running
while read -r app; do
  if [ -n "$app" ]; then
    args+=(--remove "app.$app")
  fi
done <<< "$apps_to_remove"

# Process all current apps
while read -r app; do
  if [ -z "$app" ]; then continue; fi

  # Get the icon
  icon=$("$CONFIG_DIR/plugins/icon_map.sh" "$app")
  
  # Fetch notification label (StatusLabel)
  # NOTE: lsappinfo can be slow. If you notice lag when switching apps, 
  # consider removing this check or limiting it to specific apps.
  label=$(lsappinfo info -only StatusLabel "$(lsappinfo find LSDisplayName="$app")" | grep -o '\"StatusLabel\"=\"[^\"]*\"' | cut -d'"' -f4)

  if [ -z "$label" ] || [ "$label" = "null" ]; then
    drawing="off"
    label_str=""
  else
    drawing="on"
    label_str="$label"
  fi

  # Use grep -Fx to check for literal string match (prevents regex issues with app names)
  if echo "$apps_to_add" | grep -Fxq "$app"; then
    # Add new app item
    args+=(--add item "app.$app" right \
           --set "app.$app" \
                 icon="$icon" \
                 icon.font="sketchybar-app-font:Regular:16.0" \
                 label="$label_str" \
                 label.drawing="$drawing" \
                 label.padding_right=5 \
                 label.font="Hack Nerd Font:Bold:10.0" \
                 label.color=0xfff38ba8 \
                 background.drawing=on \
                 background.color=0x20ffffff \
                 background.corner_radius=5 \
                 click_script="open -a '$app'")
  else
    # Update existing app item (avoids flashing)
    args+=(--set "app.$app" \
                 icon="$icon" \
                 label="$label_str" \
                 label.drawing="$drawing")
  fi
done <<< "$current_apps"

# Reorder all app items to maintain consistent alphabetical order
if [ -n "$current_apps" ]; then
  reorder_list=()
  while read -r app; do
    if [ -n "$app" ]; then
      reorder_list+=("app.$app")
    fi
  done <<< "$current_apps"
  
  if [ ${#reorder_list[@]} -gt 0 ]; then
    args+=(--reorder "${reorder_list[@]}")
  fi
fi

# Execute all changes in a single batch for maximum efficiency
if [ ${#args[@]} -gt 0 ]; then
  sketchybar "${args[@]}"
fi
