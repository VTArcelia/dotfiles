#!/bin/sh

options=$(wpctl status \
  | sed -n '/├─ Sinks:/,/├─ Sources:/p' \
  | grep -E '[│|][[:space:]]+(\* )?[0-9]+\.' \
  | sed -E 's/.*[│|][[:space:]]+(\* )?([0-9]+)\.\s*/\2 /')

selection=$(printf "%s\n" "$options" | rofi -dmenu -i -p "Output:")

sink_id=$(printf "%s" "$selection" | awk '{print $1}')

if [ -n "$sink_id" ]; then
    wpctl set-default "$sink_id" && notify-send "Audio switched to: $selection"
else
    notify-send "Audio switch failed"
fi
