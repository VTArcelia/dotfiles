#!/bin/sh

options=$(wpctl status \
  | sed -n '/├─ Sources:/,/├─ Filters:/p' \
  | grep -E '[│|][[:space:]]+(\* )?[0-9]+\.' \
  | sed -E 's/.*[│|][[:space:]]+(\* )?([0-9]+)\.\s*/\2 /')

selection=$(printf "%s\n" "$options" | rofi -dmenu -i -p "Input:")

source_id=$(printf "%s" "$selection" | awk '{print $1}')

if [ -n "$source_id" ]; then
    wpctl set-default "$source_id" && notify-send "Input switched to: $selection"
else
    notify-send "Input switch failed"
fi

