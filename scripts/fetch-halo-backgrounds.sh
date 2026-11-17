#!/usr/bin/env bash
# Fetch the optional Halo & military wallpaper set for Mecha Green.
#
# The images are fan / © Microsoft–343 Industries / third-party artwork from
# Wallhaven. They are NOT part of the MIT theme and are downloaded only for
# personal desktop use. Do not redistribute them.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES_DIR="${OMARCHY_THEMES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/themes}"
DARK_DIR="$THEMES_DIR/mecha-green/backgrounds"
LIGHT_DIR="$THEMES_DIR/mecha-green-light/backgrounds"
LUT_OLIVE="$ROOT/assets/lut-olive-amber.png"
LUT_HERO="$ROOT/assets/lut-hero.png"
LUT_TRI="$ROOT/assets/lut-tritone.png"
THEMETIZE="$ROOT/scripts/mecha-themetize"
FORCE=0
YES=0
DARK=1
LIGHT=1
SETS="all"

# Curated sets. Fields: set|dark number|slug|Wallhaven id|extension.
# Light files use one number lower (21-41), so the same slug stays together.
HALO_SETS=(
  "spartans|22|chief-noir|0je6vp|jpg"
  "spartans|23|chief-blue|6qjwel|png"
  "spartans|24|helmet-amber|83qpoy|jpg"
  "spartans|25|chief-rain|lq887r|jpg"
  "spartans|26|spartan-visor|435686|jpg"
  "unsc|27|unsc-frigate|4537m8|jpg"
  "unsc|28|unsc-city|g8le3e|jpg"
  "unsc|29|odst-squad|lm7l9p|jpg"
  "unsc|30|pelican-drop|oxep9p|jpg"
  "unsc|31|warthog-sunset|vgj8z8|png"
  "covenant|32|elite-portrait|4d3lrl|jpg"
  "covenant|33|elite-night|kw6qq7|jpg"
  "covenant|34|arbiter-duel|mdmkem|png"
  "covenant|35|elite-closeup|mpq2o1|png"
  "covenant|36|energy-swords|z8gmyo|jpg"
  "forerunner|37|forerunner-spire|39pgl3|png"
  "forerunner|38|ring-arc|dpvvgm|jpg"
  "forerunner|39|forerunner-temple|ey1mll|png"
  "forerunner|40|forerunner-snow|kwomm1|png"
  "forerunner|41|chief-sunset|l3o6yl|jpg"
  "forerunner|42|ring-horizon|y8ldqd|jpg"
)

usage() {
  cat <<'EOF'
Usage: fetch-halo-backgrounds.sh [options]

Downloads and grades the Halo & military wallpaper set into the installed
Mecha Green themes. Existing files are kept unless --force is given.

Options:
  --dark-only              Only fetch the dark set
  --light-only             Only fetch the light set
  --set LIST               Curated sets: spartans, unsc, covenant, forerunner,
                           all (default). Comma-separate to pick several.
  --list-sets              Show the curated sets and exit
  --force                  Overwrite existing files
  --yes, -y                Skip the personal-use confirmation
  -h, --help               Show this help
EOF
}

list_sets() {
  cat <<'EOF'
Curated Halo sets (five files each, six for forerunner):

  spartans     Chief and Spartan portraits
  unsc         Ships, ODSTs, Pelicans and a Warthog
  covenant     Elites, Arbiter and energy swords
  forerunner   Spires, rings, temples and ring horizons

Pass --set spartans,unsc to fetch only those sets. Both themes get the same
slugs; dark uses 22-42 and light uses 21-41.
EOF
}

while (( $# > 0 )); do
  case "$1" in
    --force) FORCE=1 ;;
    --yes|-y) YES=1 ;;
    --dark-only) LIGHT=0 ;;
    --light-only) DARK=0 ;;
    --set|--sets)
      if (( $# < 2 )); then
        echo "--set needs spartans, unsc, covenant, forerunner or all" >&2
        exit 2
      fi
      SETS="$2"
      shift
      ;;
    --list-sets) list_sets; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

SETS="${SETS// /}"
if [[ $SETS == all || -z $SETS ]]; then
  SETS="all"
else
  IFS=',' read -ra _requested_sets <<< "$SETS"
  for _set in "${_requested_sets[@]}"; do
    case "$_set" in
      spartans|unsc|covenant|forerunner) ;;
      *) echo "unknown set: $_set (use --list-sets)" >&2; exit 2 ;;
    esac
  done
fi

command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 1; }
command -v magick >/dev/null 2>&1 || { echo "ImageMagick (magick) is required" >&2; exit 1; }
for lut in "$LUT_OLIVE" "$LUT_HERO" "$LUT_TRI"; do
  [[ -f $lut ]] || { echo "missing LUT: $lut" >&2; exit 1; }
done
[[ -x $THEMETIZE ]] || { echo "missing themetize script: $THEMETIZE" >&2; exit 1; }

if (( ! YES )); then
  cat <<'EOF'
The Halo & military wallpaper set is fan / © Microsoft–343 Industries /
third-party artwork from Wallhaven. It is licensed for personal desktop use
only and is not covered by the MIT license of this theme. Continue? [y/N]
EOF
  read -r answer
  [[ ${answer:-} =~ ^[Yy]$ ]] || exit 0
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

wanted() {
  local path="$1"
  if [[ -f $path && $FORCE -eq 0 ]]; then
    echo "  keep  $(basename "$path")" >&2
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

set_selected() {
  [[ $SETS == all ]] && return 0
  [[ ",$SETS," == *",$1,"* ]]
}

# Crop the bottom 8% to remove publisher watermarks, then grade and fit.
fetch_curated_sets() {
  local mode="$1" dir numoff entry set num slug id ext out src h chop
  if [[ $mode == dark ]]; then
    dir="$DARK_DIR"; numoff=0
  else
    dir="$LIGHT_DIR"; numoff=-1
  fi

  for entry in "${HALO_SETS[@]}"; do
    IFS='|' read -r set num slug id ext <<< "$entry"
    set_selected "$set" || continue
    out="$dir/$(printf '%02d' $((num + numoff)))-$slug.webp"
    if [[ -f $out && $FORCE -eq 0 ]]; then
      echo "  keep  $(basename "$out")" >&2
      continue
    fi
    download "$id" "https://w.wallhaven.cc/full/${id:0:2}/wallhaven-$id.$ext" "$ext"
    src="$TMP/$id-clean.png"
    if [[ ! -f $src ]]; then
      h=$(magick identify -format '%h' "$TMP/$id.$ext")
      chop=$((h * 8 / 100))
      magick "$TMP/$id.$ext" -gravity south -chop "0x${chop}" +repage "$src"
    fi
    "$THEMETIZE" "$src" "$out" --mode "$mode" --strength 80 --fit 2560x1440
  done
}

mkdir -p "$DARK_DIR" "$LIGHT_DIR"

# Remove the old blue-heavy scenes from earlier releases.
rm -f "$DARK_DIR/5-forerunner-gate.webp"
rm -f "$LIGHT_DIR/1-dawn-ring.webp" "$LIGHT_DIR/2-field-light.webp" "$LIGHT_DIR/3-canyon-light.webp"

if (( DARK )); then
  echo "Mecha Green (dark)"
  want_master=$(wanted "$DARK_DIR/1-master-chief.webp" && echo 1 || echo 0)
  want_amber=$(wanted "$DARK_DIR/2-amber-chief.webp" && echo 1 || echo 0)
  want_dark=$(wanted "$DARK_DIR/3-chief-dark.webp" && echo 1 || echo 0)
  want_night=$(wanted "$DARK_DIR/4-night-ring.webp" && echo 1 || echo 0)
  want_warthog=$(wanted "$DARK_DIR/5-warthog.webp" && echo 1 || echo 0)
  want_fire=$(wanted "$DARK_DIR/6-fireteam.webp" && echo 1 || echo 0)
  want_canyon=$(wanted "$DARK_DIR/7-canyon.webp" && echo 1 || echo 0)

  (( want_master )) && download 85qdg2 'https://w.wallhaven.cc/full/85/wallhaven-85qdg2.jpg' jpg
  (( want_amber )) && download 4x7leo 'https://w.wallhaven.cc/full/4x/wallhaven-4x7leo.jpg' jpg
  (( want_dark )) && download 3lovdd 'https://w.wallhaven.cc/full/3l/wallhaven-3lovdd.jpg' jpg
  (( want_night )) && download 9odk5d 'https://w.wallhaven.cc/full/9o/wallhaven-9odk5d.png' png
  (( want_warthog )) && download 5dy1j8 'https://w.wallhaven.cc/full/5d/wallhaven-5dy1j8.jpg' jpg
  (( want_fire )) && download eo8ggr 'https://w.wallhaven.cc/full/eo/wallhaven-eo8ggr.jpg' jpg
  (( want_canyon )) && download 5wwdz7 'https://w.wallhaven.cc/full/5w/wallhaven-5wwdz7.png' png

  if (( want_master )); then
    magick "$TMP/85qdg2.jpg" -crop 3840x2080+0+0 +repage -resize 2560x1440^ -gravity center -extent 2560x1440 \
      "$TMP/hero-base.png"
    magick "$TMP/hero-base.png" -fx '(b > r*1.15 && b > g*1.03) ? 1 : 0' -blur 0x3 "$TMP/hero-mask.png"
    magick "$TMP/hero-base.png" -colorspace gray -auto-level "$LUT_HERO" -clut "$TMP/hero-lut.png"
    magick "$TMP/hero-base.png" "$TMP/hero-lut.png" "$TMP/hero-mask.png" -composite \
      -modulate 96,90,100 -fill '#1b2412' -colorize 5% -brightness-contrast -3x8 \
      -background '#080a06' -vignette 0x450 -quality 92 "$DARK_DIR/1-master-chief.webp"
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
      -colorspace gray -auto-level "$LUT_OLIVE" -clut -brightness-contrast 2x4 \
      -background '#080a06' -vignette 0x350 -quality 92 "$DARK_DIR/4-night-ring.webp"
  fi
  if (( want_warthog )); then
    magick "$TMP/5dy1j8.jpg" -crop 1890x1040+0+0 +repage -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 95,85,103 -fill '#2b331a' -colorize 10% -brightness-contrast -3x8 \
      -background '#080a06' -vignette 0x350 -quality 92 "$DARK_DIR/5-warthog.webp"
  fi
  if (( want_fire )); then
    magick "$TMP/eo8ggr.jpg" -crop 2560x1103+0+169 +repage -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -colorspace gray -auto-level "$LUT_OLIVE" -clut -brightness-contrast 6x8 \
      -background '#080a06' -vignette 0x350 -quality 92 "$DARK_DIR/6-fireteam.webp"
  fi
  if (( want_canyon )); then
    magick "$TMP/5wwdz7.png" -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 90,82,104 -fill '#1b2412' -colorize 10% -brightness-contrast -5x8 \
      -background '#080a06' -vignette 0x350 -quality 92 "$DARK_DIR/7-canyon.webp"
  fi

  echo "  Halo & military set (dark)"
  want_dawn=$(wanted "$DARK_DIR/16-halo-dawn.webp" && echo 1 || echo 0)
  want_gate=$(wanted "$DARK_DIR/17-forerunner-gate.webp" && echo 1 || echo 0)
  want_canyon2=$(wanted "$DARK_DIR/18-warthog-canyon.webp" && echo 1 || echo 0)
  want_tank=$(wanted "$DARK_DIR/19-tank-dust.webp" && echo 1 || echo 0)
  want_helisun=$(wanted "$DARK_DIR/20-helicopter-sunset.webp" && echo 1 || echo 0)
  want_jet=$(wanted "$DARK_DIR/21-jet-night.webp" && echo 1 || echo 0)

  (( want_dawn )) && download e725e8 'https://w.wallhaven.cc/full/e7/wallhaven-e725e8.jpg' jpg
  (( want_gate )) && download j5o29p 'https://w.wallhaven.cc/full/j5/wallhaven-j5o29p.jpg' jpg
  (( want_canyon2 )) && download wyrz9q 'https://w.wallhaven.cc/full/wy/wallhaven-wyrz9q.jpg' jpg
  (( want_tank )) && download 0jwrjy 'https://w.wallhaven.cc/full/0j/wallhaven-0jwrjy.jpg' jpg
  (( want_helisun )) && download 4lxrdp 'https://w.wallhaven.cc/full/4l/wallhaven-4lxrdp.jpg' jpg
  (( want_jet )) && download 42vrp6 'https://w.wallhaven.cc/full/42/wallhaven-42vrp6.jpg' jpg

  if (( want_dawn )); then
    [[ -f "$TMP/halo-dawn.jpg" ]] || magick "$TMP/e725e8.jpg" -crop 3840x2000+0+0 +repage "$TMP/halo-dawn.jpg"
    "$THEMETIZE" "$TMP/halo-dawn.jpg" "$DARK_DIR/16-halo-dawn.webp" --mode dark --strength 80 --fit 2560x1440
  fi
  if (( want_gate )); then
    [[ -f "$TMP/forerunner-gate.jpg" ]] || magick "$TMP/j5o29p.jpg" -gravity north -crop 100%x2692+0+0 +repage "$TMP/forerunner-gate.jpg"
    "$THEMETIZE" "$TMP/forerunner-gate.jpg" "$DARK_DIR/17-forerunner-gate.webp" --mode dark --strength 80 --fit 2560x1440
  fi
  if (( want_canyon2 )); then
    [[ -f "$TMP/warthog-canyon.jpg" ]] || magick "$TMP/wyrz9q.jpg" -gravity north -crop 100%x1658+0+0 +repage "$TMP/warthog-canyon.jpg"
    "$THEMETIZE" "$TMP/warthog-canyon.jpg" "$DARK_DIR/18-warthog-canyon.webp" --mode dark --strength 80 --fit 2560x1440
  fi
  if (( want_tank )); then
    "$THEMETIZE" "$TMP/0jwrjy.jpg" "$DARK_DIR/19-tank-dust.webp" --mode dark --strength 80 --fit 2560x1440
  fi
  if (( want_helisun )); then
    "$THEMETIZE" "$TMP/4lxrdp.jpg" "$DARK_DIR/20-helicopter-sunset.webp" --mode dark --strength 80 --fit 2560x1440
  fi
  if (( want_jet )); then
    "$THEMETIZE" "$TMP/42vrp6.jpg" "$DARK_DIR/21-jet-night.webp" --mode dark --strength 80 --fit 2560x1440
  fi

  echo "  Curated sets (dark): $SETS"
  fetch_curated_sets dark
fi

if (( LIGHT )); then
  echo "Mecha Green Light"
  want_warthog_l=$(wanted "$LIGHT_DIR/1-warthog-light.webp" && echo 1 || echo 0)
  want_canyon_l=$(wanted "$LIGHT_DIR/2-canyon-light.webp" && echo 1 || echo 0)
  want_desert_l=$(wanted "$LIGHT_DIR/3-desert-light.webp" && echo 1 || echo 0)
  want_jungle_l=$(wanted "$LIGHT_DIR/4-jungle-light.webp" && echo 1 || echo 0)

  (( want_warthog_l )) && download 5dy1j8 'https://w.wallhaven.cc/full/5d/wallhaven-5dy1j8.jpg' jpg
  (( want_canyon_l )) && download 5wwdz7 'https://w.wallhaven.cc/full/5w/wallhaven-5wwdz7.png' png
  (( want_desert_l )) && download oxer87 'https://w.wallhaven.cc/full/ox/wallhaven-oxer87.jpg' jpg
  (( want_jungle_l )) && download zmreeg 'https://w.wallhaven.cc/full/zm/wallhaven-zmreeg.jpg' jpg

  if (( want_warthog_l )); then
    magick "$TMP/5dy1j8.jpg" -crop 1890x1040+0+0 +repage -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 105,90,103 -fill '#f0ecd2' -colorize 4% -brightness-contrast 2x4 -quality 92 "$LIGHT_DIR/1-warthog-light.webp"
  fi
  if (( want_canyon_l )); then
    magick "$TMP/5wwdz7.png" -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -modulate 105,90,102 -fill '#f0ecd2' -colorize 6% -brightness-contrast 2x4 -quality 92 "$LIGHT_DIR/2-canyon-light.webp"
  fi
  if (( want_desert_l )); then
    magick "$TMP/oxer87.jpg" -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -colorspace gray -auto-level "$LUT_TRI" -clut -brightness-contrast 6x3 -quality 92 "$LIGHT_DIR/3-desert-light.webp"
  fi
  if (( want_jungle_l )); then
    magick "$TMP/zmreeg.jpg" -resize 2560x1440^ -gravity center -extent 2560x1440 \
      -colorspace gray -auto-level "$LUT_TRI" -clut -brightness-contrast 8x3 -quality 92 "$LIGHT_DIR/4-jungle-light.webp"
  fi

  echo "  Halo & military set (light)"
  want_dawn_l=$(wanted "$LIGHT_DIR/16-halo-dawn.webp" && echo 1 || echo 0)
  want_gate_l=$(wanted "$LIGHT_DIR/17-forerunner-gate.webp" && echo 1 || echo 0)
  want_canyon2_l=$(wanted "$LIGHT_DIR/18-warthog-canyon.webp" && echo 1 || echo 0)
  want_tank_l=$(wanted "$LIGHT_DIR/19-tank-dust.webp" && echo 1 || echo 0)
  want_snow_l=$(wanted "$LIGHT_DIR/20-helicopter-snow.webp" && echo 1 || echo 0)

  (( want_dawn_l )) && download e725e8 'https://w.wallhaven.cc/full/e7/wallhaven-e725e8.jpg' jpg
  (( want_gate_l )) && download j5o29p 'https://w.wallhaven.cc/full/j5/wallhaven-j5o29p.jpg' jpg
  (( want_canyon2_l )) && download wyrz9q 'https://w.wallhaven.cc/full/wy/wallhaven-wyrz9q.jpg' jpg
  (( want_tank_l )) && download 0jwrjy 'https://w.wallhaven.cc/full/0j/wallhaven-0jwrjy.jpg' jpg
  (( want_snow_l )) && download nmkkq1 'https://w.wallhaven.cc/full/nm/wallhaven-nmkkq1.jpg' jpg

  if (( want_dawn_l )); then
    [[ -f "$TMP/halo-dawn.jpg" ]] || magick "$TMP/e725e8.jpg" -crop 3840x2000+0+0 +repage "$TMP/halo-dawn.jpg"
    "$THEMETIZE" "$TMP/halo-dawn.jpg" "$LIGHT_DIR/16-halo-dawn.webp" --mode light --strength 80 --fit 2560x1440
  fi
  if (( want_gate_l )); then
    [[ -f "$TMP/forerunner-gate.jpg" ]] || magick "$TMP/j5o29p.jpg" -gravity north -crop 100%x2692+0+0 +repage "$TMP/forerunner-gate.jpg"
    "$THEMETIZE" "$TMP/forerunner-gate.jpg" "$LIGHT_DIR/17-forerunner-gate.webp" --mode light --strength 80 --fit 2560x1440
  fi
  if (( want_canyon2_l )); then
    [[ -f "$TMP/warthog-canyon.jpg" ]] || magick "$TMP/wyrz9q.jpg" -gravity north -crop 100%x1658+0+0 +repage "$TMP/warthog-canyon.jpg"
    "$THEMETIZE" "$TMP/warthog-canyon.jpg" "$LIGHT_DIR/18-warthog-canyon.webp" --mode light --strength 80 --fit 2560x1440
  fi
  if (( want_tank_l )); then
    "$THEMETIZE" "$TMP/0jwrjy.jpg" "$LIGHT_DIR/19-tank-dust.webp" --mode light --strength 80 --fit 2560x1440
  fi
  if (( want_snow_l )); then
    [[ -f "$TMP/helicopter-snow.jpg" ]] || magick "$TMP/nmkkq1.jpg" -gravity north -crop 100%x1380+0+0 +repage "$TMP/helicopter-snow.jpg"
    "$THEMETIZE" "$TMP/helicopter-snow.jpg" "$LIGHT_DIR/20-helicopter-snow.webp" --mode light --strength 80 --fit 2560x1440
  fi

  echo "  Curated sets (light): $SETS"
  fetch_curated_sets light
fi

echo "Done. Cycle them with: omarchy theme bg next"
