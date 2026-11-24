#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for cmd in rsvg-convert magick; do
  command -v "$cmd" >/dev/null || {
    printf 'Missing required command: %s\n' "$cmd" >&2
    exit 1
  }
done

render_theme() {
  local mode="$1" theme="$2" source="$3" output="$4"
  local wallpaper="$ROOT/themes/$theme/backgrounds/$output"
  local preview="$ROOT/themes/$theme/preview.png"

  rsvg-convert --width 2560 --height 1440 "$ROOT/$source" |
    magick png:- -strip -quality 92 "$wallpaper"
  magick "$wallpaper" -resize 1200x675 -strip "$preview"
  cp -f "$preview" "$ROOT/screenshots/mecha-green${mode}.png"

  printf 'Rendered %s\n' "$wallpaper"
}

render_theme "" "mecha-green" "assets/svg/topo-dark.svg" "0-topographic.webp"
render_theme "-light" "mecha-green-light" "assets/svg/topo-light.svg" "0-topographic-light.webp"
