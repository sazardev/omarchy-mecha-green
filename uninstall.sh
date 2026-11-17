#!/usr/bin/env bash
# Remove the Mecha Green themes, plugins and CLI.
set -euo pipefail

THEMES_DIR="${OMARCHY_THEMES_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/themes}"
PLUGINS_DIR="${OMARCHY_PLUGINS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy"
BIN_DIR="${MECHA_BIN_DIR:-$HOME/.local/bin}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/omarchy-mecha-green"
ASSUME_YES=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --yes|-y) ASSUME_YES=1 ;;
    --force) FORCE=1 ;;
    -h|--help)
      echo "Usage: uninstall.sh [--yes] [--force]"
      exit 0
      ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

if command -v omarchy >/dev/null 2>&1 && (( ! FORCE )); then
  current="$(omarchy theme current 2>/dev/null || true)"
  if [[ $current == "Mecha Green" || $current == "Mecha Green Light" ]]; then
    echo "The current theme is '$current'. Switch away first:"
    echo "  omarchy theme set \"Temerald\""
    echo "Then run this again, or pass --force."
    exit 1
  fi
fi

if (( ! ASSUME_YES )); then
  cat <<'EOF'
This removes the Mecha Green themes, the Mecha HUD/NET plugins and the
mecha-status CLI. Continue? [y/N]
EOF
  read -r answer
  [[ ${answer:-} =~ ^[Yy]$ ]] || exit 0
fi

# Remove the widgets from shell.json so the bar does not keep empty entries.
SHELL_JSON="$CONFIG_DIR/shell.json"
if [[ -f $SHELL_JSON ]] && command -v jq >/dev/null 2>&1; then
  cp "$SHELL_JSON" "$SHELL_JSON.bak.$(date +%s)"
  tmp="$(mktemp)"
  if jq '.bar.layout |= with_entries(.value |= map(select(.id != "sazardev.mecha-hud" and .id != "sazardev.ping")))' \
      "$SHELL_JSON" >"$tmp"; then
    mv "$tmp" "$SHELL_JSON"
  else
    rm -f "$tmp"
  fi
fi

rm -rf "$THEMES_DIR/mecha-green" "$THEMES_DIR/mecha-green-light"
rm -rf "$PLUGINS_DIR/sazardev.mecha-hud" "$PLUGINS_DIR/sazardev.ping"
rm -rf "$DATA_DIR"
rm -f "$BIN_DIR/mecha-status" "$BIN_DIR/ping-status" "$BIN_DIR/mecha-fetch-halo"

if command -v omarchy >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  echo "Removed. Restart the shell to clear the bar: omarchy restart shell"
else
  echo "Removed."
fi
