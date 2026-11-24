#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDDM="$ROOT/system/sddm/mecha-green"
PLYMOUTH="$ROOT/system/plymouth/mecha-green"

for cmd in rsvg-convert magick fc-match; do
  command -v "$cmd" >/dev/null || {
    printf 'Missing required command: %s\n' "$cmd" >&2
    exit 1
  }
done

FONT_SANS="$(fc-match -f '%{file}' 'Geist:style=Medium')"
FONT_MONO="$(fc-match -f '%{file}' 'Geist Mono:style=Regular')"

rsvg-convert --width 2560 --height 1440 "$SDDM/background.svg" \
  | magick png:- -strip -quality 92 "$SDDM/background.webp"

rsvg-convert --width 2560 --height 1440 "$SDDM/background.svg" \
  | magick png:- -strip "$PLYMOUTH/background.png"

magick "$PLYMOUTH/background.png" \
  \( "$PLYMOUTH/logo.png" -resize 800x188 \) \
  -gravity center -geometry +0-70 -composite \
  \( "$PLYMOUTH/progress_box.png" -resize 300x10 \) \
  -gravity center -geometry +0+90 -composite \
  \( "$PLYMOUTH/progress_bar.png" -resize 180x10 \) \
  -gravity center -geometry +0+90 -composite \
  -quality 92 "$PLYMOUTH/preview.webp"
cp -f "$PLYMOUTH/preview.webp" "$ROOT/screenshots/plymouth-preview.webp"

magick "$SDDM/background.webp" \
  \( "$SDDM/logo.png" -resize 800x188 \) \
  -gravity center -geometry +0-90 -composite \
  -font "$FONT_SANS" -pointsize 42 -fill '#d8d9b4' \
  -gravity center -annotate +0+20 'sazar' \
  -stroke '#f2c84b' -strokewidth 3 -fill '#0e1009' \
  -draw 'roundrectangle 710,785,1210,885,12,12' \
  -stroke none -font "$FONT_MONO" -pointsize 24 -fill '#bcc09a' \
  -gravity center -annotate +0+106 'ENTER PASSWORD' \
  -quality 92 "$SDDM/preview.webp"
cp -f "$SDDM/preview.webp" "$ROOT/screenshots/login-preview.webp"

printf 'Rendered SDDM and Plymouth topographic assets\n'
