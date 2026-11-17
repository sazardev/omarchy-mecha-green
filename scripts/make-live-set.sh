#!/usr/bin/env bash
# make-live-set — build the curated Halo live wallpaper set from fetched stills.
#
# Run fetch-halo-backgrounds.sh first. The stills are already palette-graded, so
# these loops use --no-filter and only add motion, HUD overlays and grain.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIVEWALL="$ROOT/scripts/mecha-livewall"
THEMES_DIR="${OMARCHY_THEMES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/themes}"
USER_BG="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/backgrounds"
FORCE=0
DARK=1
LIGHT=1
MADE=0

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --dark-only) LIGHT=0 ;;
    --light-only) DARK=0 ;;
    -h|--help)
      cat <<'EOF'
Usage: make-live-set.sh [--dark-only|--light-only] [--force]

Builds the curated Halo live wallpapers from the stills installed by
fetch-halo-backgrounds.sh:

  Spartans / UNSC / Covenant / Forerunner
  dark:  7 loops
  light: 5 loops

Files are written to ~/.config/omarchy/backgrounds/<theme>/live-*.mp4, so
they survive theme updates. Run omarchy theme bg next (or the HUD NEXT LIVE
button) to cycle them.
EOF
      exit 0
      ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

[[ -x $LIVEWALL ]] || { echo "missing livewall script: $LIVEWALL" >&2; exit 1; }

render() {
  local mode="$1" slug="$2" source="$3" style="$4"
  local theme="$5"
  local src="$THEMES_DIR/$theme/backgrounds/$source"
  local dest="$USER_BG/$theme/live-$slug.mp4"
  local args=("$src" "$dest" --no-filter --mode "$mode" --style "$style" --name "$slug")
  (( FORCE )) && args+=(--force)

  if [[ ! -f $src ]]; then
    echo "  skip  $source (run fetch-halo-backgrounds.sh first)" >&2
    return 0
  fi
  if [[ -e $dest && $FORCE -eq 0 ]]; then
    echo "  keep  $theme/$slug" >&2
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  echo "  live  $theme/$slug ($style)" >&2
  "$LIVEWALL" "${args[@]}" >/dev/null
  MADE=$((MADE + 1))
}

if (( DARK )); then
  echo "Mecha Green live set"
  render dark unsc-city       28-unsc-city.webp       command mecha-green
  render dark chief-rain      25-chief-rain.webp      rain    mecha-green
  render dark covenant-portrait 32-elite-portrait.webp command mecha-green
  render dark ring-arc        38-ring-arc.webp        pulse   mecha-green
  render dark warthog-sunset  31-warthog-sunset.webp  dust    mecha-green
  render dark forerunner-spire 37-forerunner-spire.webp pulse  mecha-green
  render dark energy-swords   36-energy-swords.webp   pulse   mecha-green
fi

if (( LIGHT )); then
  echo "Mecha Green Light live set"
  render light unsc-city       27-unsc-city.webp        command mecha-green-light
  render light chief-rain      24-chief-rain.webp       rain    mecha-green-light
  render light forerunner-snow 39-forerunner-snow.webp  pulse   mecha-green-light
  render light warthog-sunset  30-warthog-sunset.webp   dust    mecha-green-light
  render light ring-arc        37-ring-arc.webp         pulse   mecha-green-light
fi

if (( MADE == 0 )); then
  echo "nothing generated: fetch the Halo stills first" >&2
  exit 1
fi

command -v omarchy >/dev/null 2>&1 && omarchy theme bg cache >/dev/null 2>&1 || true
echo "Done. $MADE live wallpaper(s). Cycle with: mecha-live-next"
echo "The HUD NEXT LIVE button runs the same command."
