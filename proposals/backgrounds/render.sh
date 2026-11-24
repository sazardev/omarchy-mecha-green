#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$root/rendered" "$root/thumbs"

for source in "$root"/svg/*.svg; do
  name="$(basename "$source" .svg)"
  tmp="$(mktemp --suffix=.png)"
  trap 'rm -f "$tmp"' EXIT
  rsvg-convert --width 2560 --height 1440 "$source" --output "$tmp"
  magick "$tmp" -strip -quality 92 "$root/rendered/$name.webp"
  magick "$root/rendered/$name.webp" -resize 1280x720 "$root/thumbs/$name.webp"
  rm -f "$tmp"
  trap - EXIT
  printf 'Rendered %s\n' "$name"
done

magick montage \
  "$root/rendered/01-drift-dark.webp" \
  "$root/rendered/01-drift-light.webp" \
  "$root/rendered/02-fold-dark.webp" \
  "$root/rendered/02-fold-light.webp" \
  "$root/rendered/03-field-dark.webp" \
  "$root/rendered/03-field-light.webp" \
  "$root/rendered/04-terrain-dark.webp" \
  "$root/rendered/04-terrain-light.webp" \
  "$root/rendered/05-panorama-dark.webp" \
  "$root/rendered/05-panorama-light.webp" \
  "$root/rendered/06-undulate-dark.webp" \
  "$root/rendered/06-undulate-light.webp" \
  -thumbnail 1280x720 -tile 2x6 -geometry +20+20 \
  -background '#e9e5cb' "$root/gallery.webp"
