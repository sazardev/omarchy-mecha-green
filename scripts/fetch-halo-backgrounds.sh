#!/usr/bin/env bash
# Fetch the optional Halo wallpaper set for Mecha Green.
#
# The images are Halo fan / © Microsoft–343 Industries artwork from Wallhaven.
# They are NOT part of the MIT theme and are downloaded only for personal
# desktop use. Do not redistribute them.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="${OMARCHY_THEMES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/themes}"
DARK_DIR="$THEMES_DIR/mecha-green/backgrounds"
LIGHT_DIR="$THEMES_DIR/mecha-green-light/backgrounds"
LUT="$ROOT/assets/lut-olive-amber.png"
FORCE=0
YES=0
DARK=1
LIGHT=1

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --yes|-y) YES=1 ;;
    --dark-only) LIGHT=0 ;;
    --light-only) DARK=0 ;;
    -h|--help)
      cat <<'EOF'
Usage: fetch-halo-backgrounds.sh [--dark-only|--light-only] [--force] [--yes]

Downloads and grades the Halo wallpaper set into the installed Mecha Green
themes. Existing files are kept unless --force is given.
EOF
      exit 0
      ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 1; }
command -v magick >/dev/null 2>&1 || { echo "ImageMagick (magick) is required" >&2; exit 1; }
[[ -f $LUT ]] || { echo "missing LUT: $LUT" >&2; exit 1; }

if (( ! YES )); then
  cat <<'EOF'
The Halo wallpaper set is fan / © Microsoft–343 Industries artwork from
Wallhaven. It is licensed for personal desktop use only and is not covered by
the MIT license of this theme. Continue? [y/N]
EOF
  read -r answer
  [[ ${answer:-} =~ ^[Yy]$ ]] || exit 0
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

wanted() {
  local path="$1"
  if [[ -f $path && $FORCE -eq 0 ]]; then
    echo "  keep  $(basename "$path")"
    return 1
  fi
  return 0
}

download() {
  local id="$1" url="$2" ext="$3"
  if [[ ! -f "$TMP/$id.$ext" ]]; then
    echo "  get   $id"
    curl -L --fail --retry 2 --silent --show-error -o "$TMP/$id.$ext" "$url"
  fi
}

mkdir -p "$DARK_DIR" "$LIGHT_DIR"

if (( DARK )); then
  echo "Mecha Green (dark)"
  want_master=$(wanted "$DARK_DIR/1-master-chief.webp" && echo 1 || echo 0)
  want_amber=$(wanted "$DARK_DIR/2-amber-chief.webp" && echo 1 || echo 0)
  want_dark=$(wanted "$DARK_DIR/3-chief-dark.webp" && echo 1 || echo 0)
  want_night=$(wanted "$DARK_DIR/4-night-ring.webp" && echo 1 || echo 0)
  want_gate=$(wanted "$DARK_DIR/5-forerunner-gate.webp" && echo 1 || echo 0)
  want_fire=$(wanted "$DARK_DIR/6-fireteam.webp" && echo 1 || echo 0)
  want_canyon=$(wanted "$DARK_DIR/7-canyon.webp" && echo 1 || echo 0)

  (( want_master )) && download 85qdg2 'https://w.wallhaven.cc/full/85/wallhaven-85qdg2.jpg' jpg
  (( want_amber )) && download 4x7leo 'https://w.wallhaven.cc/full/4x/wallhaven-4x7leo.jpg' jpg
  (( want_dark )) && download 3lovdd 'https://w.wallhaven.cc/full/3l/wallhaven-3lovdd.jpg' jpg
  (( want_night )) && download 9odk5d 'https://w.wallhaven.cc/full/9o/wallhaven-9odk5d.png' png
  (( want_gate )) && download j5o29p 'https://w.wallhaven.cc/full/j5/wallhaven-j5o29p.jpg' jpg
  (( want_fire )) && download eo8ggr 'https://w.wallhaven.cc/full/eo/wallhaven-eo8ggr.jpg' jpg
  (( want_canyon )) && download 5wwdz7 'https://w.wallhaven.cc/full/5w/wallhaven-5wwdz7.png' png

  if (( want_master )); then
    magick "$TMP/85qdg2.jpg" -crop 3840x2080+0+0 +repage -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 91,82,106 -fill '#1b2412' -colorize 12% -brightness-contrast -5x10 -gamma 0.985 \
      -background '#080a06' -vignette 0x350 -unsharp 0x0.5+0.5+0.02 -quality 92 "$DARK_DIR/1-master-chief.webp"
  fi
  if (( want_amber )); then
    magick "$TMP/4x7leo.jpg" -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 98,92,102 -fill '#1b2412' -colorize 5% -brightness-contrast -2x5 \
      -background '#0b0d07' -vignette 0x300 -unsharp 0x0.5+0.4+0.02 -quality 92 "$DARK_DIR/2-amber-chief.webp"
  fi
  if (( want_dark )); then
    magick "$TMP/3lovdd.jpg" -crop 1920x810+0+135 +repage -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 100,94,103 -fill '#1b2412' -colorize 5% -brightness-contrast 2x8 \
      -background '#080a06' -vignette 0x300 -unsharp 0x0.6+0.5+0.02 -quality 92 "$DARK_DIR/3-chief-dark.webp"
  fi
  if (( want_night )); then
    magick "$TMP/9odk5d.png" -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -colorspace gray -auto-level "$LUT" -clut -brightness-contrast 2x4 \
      -background '#080a06' -vignette 0x350 -quality 92 "$DARK_DIR/4-night-ring.webp"
  fi
  if (( want_gate )); then
    magick "$TMP/j5o29p.jpg" -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 90,88,102 -fill '#2b331a' -colorize 9% -fill '#f2c84b' -colorize 3% -brightness-contrast -4x8 \
      -background '#080a06' -vignette 0x350 -quality 92 "$DARK_DIR/5-forerunner-gate.webp"
  fi
  if (( want_fire )); then
    magick "$TMP/eo8ggr.jpg" -crop 2560x1103+0+169 +repage -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -colorspace gray -auto-level "$LUT" -clut -brightness-contrast 6x8 \
      -background '#080a06' -vignette 0x350 -quality 92 "$DARK_DIR/6-fireteam.webp"
  fi
  if (( want_canyon )); then
    magick "$TMP/5wwdz7.png" -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 90,82,104 -fill '#1b2412' -colorize 10% -brightness-contrast -5x8 \
      -background '#080a06' -vignette 0x350 -quality 92 "$DARK_DIR/7-canyon.webp"
  fi
fi

if (( LIGHT )); then
  echo "Mecha Green Light"
  want_dawn=$(wanted "$LIGHT_DIR/1-dawn-ring.webp" && echo 1 || echo 0)
  want_field=$(wanted "$LIGHT_DIR/2-field-light.webp" && echo 1 || echo 0)
  want_canyon_l=$(wanted "$LIGHT_DIR/3-canyon-light.webp" && echo 1 || echo 0)

  (( want_dawn )) && download e725e8 'https://w.wallhaven.cc/full/e7/wallhaven-e725e8.jpg' jpg
  (( want_field )) && download 85qdg2 'https://w.wallhaven.cc/full/85/wallhaven-85qdg2.jpg' jpg
  (( want_canyon_l )) && download 5wwdz7 'https://w.wallhaven.cc/full/5w/wallhaven-5wwdz7.png' png

  if (( want_dawn )); then
    magick "$TMP/e725e8.jpg" -crop 3840x2000+0+0 +repage -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 100,95,103 -fill '#f0ecd2' -colorize 3% -brightness-contrast 0x3 -quality 92 "$LIGHT_DIR/1-dawn-ring.webp"
  fi
  if (( want_field )); then
    magick "$TMP/85qdg2.jpg" -crop 3840x2080+0+0 +repage -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 105,92,103 -fill '#f0ecd2' -colorize 5% -brightness-contrast 2x4 -quality 92 "$LIGHT_DIR/2-field-light.webp"
  fi
  if (( want_canyon_l )); then
    magick "$TMP/5wwdz7.png" -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 105,90,102 -fill '#f0ecd2' -colorize 6% -brightness-contrast 2x4 -quality 92 "$LIGHT_DIR/3-canyon-light.webp"
  fi
fi

echo "Done. Cycle them with: omarchy theme bg next"
