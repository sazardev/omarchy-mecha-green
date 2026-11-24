#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROPOSAL="$ROOT/proposals/system-brand"
SDDM="$ROOT/system/sddm/mecha-green"
PLYMOUTH="$ROOT/system/plymouth/mecha-green"

for cmd in rsvg-convert magick; do
  command -v "$cmd" >/dev/null || {
    printf 'Missing required command: %s\n' "$cmd" >&2
    exit 1
  }
done

cp -f "$PROPOSAL/svg/background.svg" "$SDDM/background.svg"

rsvg-convert --width 2560 --height 1440 "$SDDM/background.svg" |
  magick png:- -strip -quality 92 "$SDDM/background.webp"
rsvg-convert --width 2560 --height 1440 "$SDDM/background.svg" |
  magick png:- -strip "$PLYMOUTH/background.png"

rsvg-convert --width 1200 --height 240 "$PROPOSAL/svg/logo.svg" --output "$SDDM/logo.png"
cp -f "$SDDM/logo.png" "$PLYMOUTH/logo.png"

draw_entry() {
  local output="$1" width="$2" height="$3" radius="$4" color="$5"
  magick -size "${width}x${height}" xc:none \
    -fill '#0e1009' -stroke "$color" -strokewidth 3 \
    -draw "roundrectangle 2,2,$((width - 3)),$((height - 3)),${radius},${radius}" \
    "$output"
}

draw_lock() {
  local output="$1" color="$2"
  magick -size 84x96 xc:none \
    -fill none -stroke "$color" -strokewidth 8 \
    -draw 'roundrectangle 22,8,62,54,20,20' \
    -fill "$color" -stroke none \
    -draw 'roundrectangle 12,42,72,88,8,8' \
    -fill '#0e1009' -draw 'rectangle 37,56,47,70' \
    "$output"
}

draw_bullet() {
  local output="$1" color="$2"
  magick -size 14x14 xc:none -fill "$color" -draw 'circle 7,7 7,2' "$output"
}

draw_entry "$SDDM/entry.png" 420 67 12 '#9dae5c'
draw_entry "$SDDM/entry-failed.png" 420 67 12 '#c85b47'
draw_lock "$SDDM/lock.png" '#9dae5c'
draw_lock "$SDDM/lock-failed.png" '#c85b47'
draw_bullet "$SDDM/bullet.png" '#9dae5c'

draw_entry "$PLYMOUTH/entry.png" 286 48 10 '#9dae5c'
draw_lock "$PLYMOUTH/lock.png" '#9dae5c'
draw_bullet "$PLYMOUTH/bullet.png" '#9dae5c'

magick -size 300x10 xc:none -fill '#1a1e11' \
  -draw 'roundrectangle 0,0,299,9,5,5' "$PLYMOUTH/progress_box.png"
magick -size 300x10 xc:none -fill '#9dae5c' \
  -draw 'roundrectangle 0,0,299,9,5,5' "$PLYMOUTH/progress_bar.png"

cp -f "$PROPOSAL/rendered/login.webp" "$SDDM/preview.webp"
cp -f "$PROPOSAL/rendered/boot.webp" "$PLYMOUTH/preview.webp"
cp -f "$SDDM/preview.webp" "$ROOT/screenshots/login-preview.webp"
cp -f "$PLYMOUTH/preview.webp" "$ROOT/screenshots/plymouth-preview.webp"

printf 'Rendered flat Mecha Green system brand assets\n'
