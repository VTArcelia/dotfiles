#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="$HOME/walls"
STATE="$HOME/.config/hypr/wallpaper"
CACHE_DIR="$HOME/.cache/thumbnails/large"
MODE="fill"

mkdir -p "$CACHE_DIR"

# Find images and sort: case-insensitive, natural numeric order
mapfile -t images < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort -f -V)

# Generate entries with thumbnails
printf '%s\0' "${images[@]}" |
while IFS= read -r -d '' file; do
    basename=$(basename "$file")
    echo -en "$basename\0icon\x1fthumbnail://$file\n"
done |
rofi -dmenu \
     -show-icons \
     -theme ~/.config/rofi/wallpaper-selector.rasi \
     -p "Select Wallpaper" |
while read -r selected; do
    if [[ -n "$selected" ]]; then
        full_path="$WALL_DIR/$selected"

        # Save selection to Hyprland wallpaper state
        echo "$full_path" > "$STATE"

        # Apply wallpaper using swaybg
        pkill -x swaybg || true
        sleep 0.2
        setsid swaybg -m "$MODE" -i "$full_path" >/dev/null 2>&1 &
    fi
done
