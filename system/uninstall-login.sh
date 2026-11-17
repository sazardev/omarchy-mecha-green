#!/usr/bin/env bash
# Remove the Mecha Green SDDM/Plymouth login theme and restore Omarchy defaults.
# Run as root: sudo ./system/uninstall-login.sh
set -euo pipefail

if (( EUID != 0 )); then
  echo "Run this uninstaller as root: sudo $0" >&2
  exit 1
fi

SDDM_DEST="/usr/share/sddm/themes/mecha-green"
PLYMOUTH_DEST="/usr/share/plymouth/themes/mecha-green"
SDDM_CONF="/etc/sddm.conf.d/99-zz-mecha-green.conf"

say() { printf '\033[38;2;242;200;75m%s\033[0m\n' "$*"; }

say "Removing Mecha Green login theme"
rm -rf "$SDDM_DEST" "$PLYMOUTH_DEST"
rm -f "$SDDM_CONF"

if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  say "Restoring the Omarchy Plymouth theme"
  plymouth-set-default-theme omarchy
  if command -v limine-mkinitcpio >/dev/null 2>&1; then
    limine-mkinitcpio
  else
    mkinitcpio -P
  fi
fi

say "Done. Log out or reboot to return to the stock login screen."
echo "If you had a custom SDDM config, restore it from /var/backups/mecha-green-login-*."
