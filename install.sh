#!/usr/bin/env bash
# Mecha Green installer for Omarchy.
# Curl-friendly: bash -c "$(curl -fsSL .../install.sh)"
set -euo pipefail

REPO_URL="https://github.com/sazardev/omarchy-mecha-green.git"
BRANCH="main"
THEMES_DIR="${OMARCHY_THEMES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/themes}"
PLUGINS_DIR="${OMARCHY_PLUGINS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins}"
BIN_DIR="${MECHA_BIN_DIR:-$HOME/.local/bin}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-mecha-green"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy"

APPLY="dark"
HUD=1
PING=0
HALO=0
FORCE=0
DRY=0

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Installs the Mecha Green and Mecha Green Light themes, the Mecha HUD plugins,
and the mecha-status CLI into the current user's Omarchy setup.

Options:
  --light        Apply Mecha Green Light instead of the dark theme
  --no-apply     Install files but do not switch the active theme
  --no-hud       Do not enable the Mecha HUD bar widget
  --ping         Also enable the standalone Mecha NET widget
  --halo         Download the optional Halo wallpaper set (personal use only)
  --force        Overwrite existing theme backgrounds and previews
  --dry-run      Print what would be installed, change nothing
  -h, --help     Show this help

Environment overrides:
  OMARCHY_THEMES_DIR, OMARCHY_PLUGINS_DIR, MECHA_BIN_DIR
  MECHA_SKIP_OMARCHY_CHECK=1  (for packaging/testing only)
EOF
}

for arg in "$@"; do
  case "$arg" in
    --light) APPLY="light" ;;
    --no-apply) APPLY="none" ;;
    --no-hud) HUD=0 ;;
    --ping) PING=1 ;;
    --halo) HALO=1 ;;
    --force) FORCE=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

say() { printf '\033[38;2;242;200;75m%s\033[0m\n' "$*"; }
ok()  { printf '\033[38;2;157;174;92m  ✓ %s\033[0m\n' "$*"; }
warn(){ printf '\033[38;2;200;91;71m  ! %s\033[0m\n' "$*" >&2; }

if ! command -v omarchy >/dev/null 2>&1 && [[ ${MECHA_SKIP_OMARCHY_CHECK:-0} != "1" ]]; then
  warn "omarchy was not found on PATH. Run this installer on an Omarchy system."
  exit 1
fi

# ---- Bootstrap when piped from curl -------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -d "$SCRIPT_DIR/themes/mecha-green" ]]; then
  command -v git >/dev/null 2>&1 || { warn "git is required for the curl installer"; exit 1; }
  say "Fetching Mecha Green…"
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP/repo" >/dev/null
  SCRIPT_DIR="$TMP/repo"
fi

# ---- Helpers ------------------------------------------------------------
install_theme() {
  local src="$1" name="$2" dest="$THEMES_DIR/$2"
  say "Theme: $name"
  if (( DRY )); then
    echo "  would install $dest"
    return
  fi
  mkdir -p "$dest/backgrounds"
  for f in colors.toml shell.toml btop.theme hyprland.lua alacritty.toml \
           icons.theme chromium.theme keyboard.rgb README.md; do
    [[ -f "$src/$f" ]] && cp -f "$src/$f" "$dest/$f"
  done
  for f in "$src"/backgrounds/*; do
    [[ -e "$f" ]] || continue
    local base
    base="$(basename "$f")"
    if [[ ! -e "$dest/backgrounds/$base" || $FORCE -eq 1 ]]; then
      cp -f "$f" "$dest/backgrounds/$base"
    fi
  done
  for f in preview.png preview-unlock.png unlock.png; do
    if [[ -f "$src/$f" && ( ! -e "$dest/$f" || $FORCE -eq 1 ) ]]; then
      cp -f "$src/$f" "$dest/$f"
    fi
  done
  ok "$dest"
}

install_plugin() {
  local src="$1" name="$2" dest="$PLUGINS_DIR/$2"
  say "Plugin: $name"
  if (( DRY )); then
    echo "  would install $dest"
    return
  fi
  mkdir -p "$dest"
  cp -f "$src"/* "$dest"/
  ok "$dest"
}

install_script() {
  local src="$1" name="$2"
  if (( DRY )); then
    echo "  would install $BIN_DIR/$name"
    return
  fi
  mkdir -p "$BIN_DIR"
  cp -f "$src" "$BIN_DIR/$name"
  chmod +x "$BIN_DIR/$name"
  ok "$BIN_DIR/$name"
}

# ---- Themes -------------------------------------------------------------
install_theme "$SCRIPT_DIR/themes/mecha-green" mecha-green
install_theme "$SCRIPT_DIR/themes/mecha-green-light" mecha-green-light

# ---- Plugins ------------------------------------------------------------
install_plugin "$SCRIPT_DIR/plugins/sazardev.mecha-hud" sazardev.mecha-hud
install_plugin "$SCRIPT_DIR/plugins/sazardev.ping" sazardev.ping

# ---- CLI + optional wallpaper fetcher -----------------------------------
install_script "$SCRIPT_DIR/scripts/mecha-status" mecha-status
install_script "$SCRIPT_DIR/scripts/ping-status" ping-status

if (( ! DRY )); then
  mkdir -p "$DATA_DIR/scripts" "$DATA_DIR/assets"
  cp -f "$SCRIPT_DIR/scripts/fetch-halo-backgrounds.sh" "$DATA_DIR/scripts/"
  cp -f "$SCRIPT_DIR/assets/lut-olive-amber.png" "$DATA_DIR/assets/"
  chmod +x "$DATA_DIR/scripts/fetch-halo-backgrounds.sh"
  cat >"$BIN_DIR/mecha-fetch-halo" <<'EOF'
#!/usr/bin/env bash
exec "${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-mecha-green/scripts/fetch-halo-backgrounds.sh" "$@"
EOF
  chmod +x "$BIN_DIR/mecha-fetch-halo"
  ok "mecha-fetch-halo"
fi

# ---- Optional Halo wallpapers -------------------------------------------
if (( HALO )); then
  say "Fetching Halo wallpapers (personal use only)…"
  if (( DRY )); then
    echo "  would run $DATA_DIR/scripts/fetch-halo-backgrounds.sh --yes"
  else
    OMARCHY_THEMES_DIR="$THEMES_DIR" "$DATA_DIR/scripts/fetch-halo-backgrounds.sh" --yes
  fi
fi

# ---- Enable bar widgets -------------------------------------------------
if (( HUD || PING )) && [[ ${MECHA_SKIP_OMARCHY_CHECK:-0} != "1" ]] && (( ! DRY )); then
  SHELL_JSON="$CONFIG_DIR/shell.json"
  if [[ -f "$SHELL_JSON" ]]; then
    cp "$SHELL_JSON" "$SHELL_JSON.bak.$(date +%s)"
  fi
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
fi

if (( HUD )) && [[ ${MECHA_SKIP_OMARCHY_CHECK:-0} != "1" ]] && (( ! DRY )); then
  say "Enabling Mecha HUD…"
  omarchy plugin enable sazardev.mecha-hud --section right --after omarchy.power 2>/dev/null || \
    warn "Mecha HUD will need to be placed by hand (omarchy plugin enable sazardev.mecha-hud)."
fi

if (( PING )) && [[ ${MECHA_SKIP_OMARCHY_CHECK:-0} != "1" ]] && (( ! DRY )); then
  say "Enabling Mecha NET…"
  omarchy plugin enable sazardev.ping --section right --after omarchy.network 2>/dev/null || \
    warn "Mecha NET will need to be placed by hand (omarchy plugin enable sazardev.ping)."
fi

# ---- Apply --------------------------------------------------------------
if (( ! DRY )) && [[ $APPLY != "none" ]] && [[ ${MECHA_SKIP_OMARCHY_CHECK:-0} != "1" ]]; then
  if [[ $APPLY == "light" ]]; then
    say "Applying Mecha Green Light…"
    omarchy theme set "Mecha Green Light"
  else
    say "Applying Mecha Green…"
    omarchy theme set "Mecha Green"
  fi
fi

# ---- Summary ------------------------------------------------------------
say ""
if (( DRY )); then
  say "Dry run complete. Nothing was changed."
else
  say "Mecha Green is installed."
fi
echo "  Themes:   $THEMES_DIR/mecha-green{,-light}"
echo "  Plugins:  $PLUGINS_DIR/sazardev.mecha-hud, $PLUGINS_DIR/sazardev.ping"
echo "  CLI:      $BIN_DIR/mecha-status"
echo ""
echo "  Switch theme:   omarchy theme set \"Mecha Green\" | \"Mecha Green Light\""
echo "  Cycle wallpaper: omarchy theme bg next"
echo "  Add the HUD:     omarchy plugin enable sazardev.mecha-hud --section right"
echo "  Add NET only:    omarchy plugin enable sazardev.ping --section right"
echo "  Fetch Halo art:  mecha-fetch-halo"
echo "  Tactical CLI:    mecha-status"
