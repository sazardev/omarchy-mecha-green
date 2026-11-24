#!/usr/bin/env bash
# Install the Mecha Green SDDM login theme and Plymouth boot splash.
# Run locally:  sudo ./system/install-login.sh
# Run via curl: sudo bash -c "$(curl -fsSL .../system/install-login.sh)"
set -euo pipefail

REPO_URL="https://github.com/sazardev/omarchy-mecha-green.git"
BRANCH="main"

if (( EUID != 0 )); then
  echo "Run this installer as root: sudo $0" >&2
  exit 1
fi

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

if [[ -d "$SCRIPT_DIR/system/sddm/mecha-green" && -d "$SCRIPT_DIR/system/plymouth/mecha-green" ]]; then
  REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  command -v git >/dev/null 2>&1 || {
    echo "git is required for the curl installer" >&2
    exit 1
  }
  printf '\033[38;2;242;200;75mFetching Mecha Green system themes…\033[0m\n'
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP/repo" >/dev/null
  REPO_DIR="$TMP/repo"
fi

SDDM_SRC="$REPO_DIR/system/sddm/mecha-green"
PLYMOUTH_SRC="$REPO_DIR/system/plymouth/mecha-green"
SDDM_DEST="/usr/share/sddm/themes/mecha-green"
PLYMOUTH_DEST="/usr/share/plymouth/themes/mecha-green"
SDDM_CONF="/etc/sddm.conf.d/99-zz-mecha-green.conf"
BACKUP_DIR="/var/backups/mecha-green-login-$(date +%Y%m%d-%H%M%S)"

say() { printf '\033[38;2;242;200;75m%s\033[0m\n' "$*"; }
ok()  { printf '\033[38;2;157;174;92m  ✓ %s\033[0m\n' "$*"; }

[[ -d $SDDM_SRC ]] || { echo "missing SDDM theme: $SDDM_SRC" >&2; exit 1; }
[[ -d $PLYMOUTH_SRC ]] || { echo "missing Plymouth theme: $PLYMOUTH_SRC" >&2; exit 1; }

mkdir -p "$BACKUP_DIR"
say "Backing up current login configuration to $BACKUP_DIR"
[[ -f /etc/plymouth/plymouthd.conf ]] && cp -a /etc/plymouth/plymouthd.conf "$BACKUP_DIR/"
if [[ -d /etc/sddm.conf.d ]]; then
  cp -a /etc/sddm.conf.d "$BACKUP_DIR/"
fi
ok "backup complete"

say "Installing SDDM theme: mecha-green"
install -d "$SDDM_DEST"
find "$SDDM_SRC" -maxdepth 1 -type f -exec install -m 644 -t "$SDDM_DEST" {} +
install -d /etc/sddm.conf.d
printf '[Theme]\nCurrent=mecha-green\n' >"$SDDM_CONF"
chmod 644 "$SDDM_CONF"
ok "$SDDM_DEST"
ok "$SDDM_CONF"

say "Installing Plymouth theme: mecha-green"
install -d "$PLYMOUTH_DEST"
find "$PLYMOUTH_SRC" -maxdepth 1 -type f \
  \( -name '*.plymouth' -o -name '*.script' -o -name '*.png' \) \
  -exec install -m 644 -t "$PLYMOUTH_DEST" {} +
ok "$PLYMOUTH_DEST"

if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  say "Selecting Plymouth theme and rebuilding the initramfs"
  plymouth-set-default-theme mecha-green
  if command -v limine-mkinitcpio >/dev/null 2>&1; then
    limine-mkinitcpio
  else
    mkinitcpio -P
  fi
  ok "Plymouth + initramfs updated"
else
  echo "plymouth-set-default-theme not found; write Theme=mecha-green to /etc/plymouth/plymouthd.conf manually." >&2
fi

say ""
say "Mecha Green login and boot theme installed."
echo "  The SDDM theme applies on the next logout or reboot."
echo "  The Plymouth splash applies on the next boot."
echo ""
echo "  SDDM theme:   $SDDM_DEST"
echo "  Plymouth:     $PLYMOUTH_DEST"
echo "  SDDM config:  $SDDM_CONF"
echo "  Backup:       $BACKUP_DIR"
echo ""
echo "  To undo:"
echo "    sudo ./system/uninstall-login.sh"
