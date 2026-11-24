#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for cmd in rsvg-convert magick; do
  command -v "$cmd" >/dev/null || {
    printf 'Missing required command: %s\n' "$cmd" >&2
    exit 1
  }
done

render_still() {
  local theme="$1" source="$2" output="$3"
  local wallpaper="$ROOT/themes/$theme/backgrounds/$output"

  rsvg-convert --width 2560 --height 1440 "$ROOT/$source" |
    magick png:- -strip -quality 92 "$wallpaper"
  printf 'Rendered %s\n' "$wallpaper"
}

render_default() {
  local mode="$1" theme="$2" source="$3" output="$4"
  local wallpaper="$ROOT/themes/$theme/backgrounds/$output"
  local preview="$ROOT/themes/$theme/preview.png"

  render_still "$theme" "$source" "$output"
  magick "$wallpaper" -resize 1200x675 -strip "$preview"
  cp -f "$preview" "$ROOT/screenshots/mecha-green${mode}.png"
}

render_default "" "mecha-green" "assets/svg/topo-dark.svg" "0-topographic.webp"
render_default "-light" "mecha-green-light" "assets/svg/topo-light.svg" "0-topographic-light.webp"

for entry in \
  "100:01:drift" \
  "101:02:fold" \
  "102:03:field" \
  "103:04:terrain" \
  "104:05:panorama" \
  "105:06:undulate"; do
  IFS=: read -r number source_number name <<< "$entry"
  render_still "mecha-green" "proposals/backgrounds/svg/${source_number}-${name}-dark.svg" "${number}-${name}.webp"
  render_still "mecha-green-light" "proposals/backgrounds/svg/${source_number}-${name}-light.svg" "${number}-${name}-light.webp"
done
