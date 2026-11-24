#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$root/rendered"
for name in login boot; do
  rsvg-convert --width 2560 --height 1440 "$root/svg/$name.svg" --output "$root/rendered/$name.png"
  magick "$root/rendered/$name.png" -strip -quality 92 "$root/rendered/$name.webp"
done
rsvg-convert --width 1200 --height 240 "$root/svg/logo.svg" --output "$root/rendered/logo.png"
rsvg-convert --width 2560 --height 1440 "$root/svg/background.svg" --output "$root/rendered/background.png"
magick "$root/rendered/background.png" -strip -quality 92 "$root/rendered/background.webp"
