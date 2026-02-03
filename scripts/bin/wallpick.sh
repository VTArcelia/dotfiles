#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="$HOME/walls"
STATE="$HOME/.config/hypr/wallpaper"
CACHE_DIR="$HOME/.cache/thumbnails/large"
MODE="fill"

mkdir -p "$CACHE_DIR"

mapfile -t images < <(
    find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        | sort -f -V
)

for file in "${images[@]}"; do
    base="$(basename "$file")"
    name="${base%.*}"
    echo -en "$name\0icon\x1fthumbnail://$file\n"
done |
rofi -dmenu \
     -matching fuzzy \
     -format i \
     -show-icons \
     -theme ~/.config/rofi/wallpaper-selector.rasi \
     -p "Select Wallpaper" |
while read -r index; do
    [[ -z "$index" ]] && exit 0

    full_path="${images[$index]}"

    echo "$full_path" > "$STATE"

    pkill -x swaybg || true
    sleep 0.2
    setsid swaybg -m "$MODE" -i "$full_path" >/dev/null 2>&1 &
    hyprctl reload
done

