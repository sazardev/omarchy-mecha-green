# System screens

The Mecha Green desktop themes live in `themes/`. This directory holds the
screens that run outside the desktop session:

```
system/
├── sddm/mecha-green/       # login screen
├── plymouth/mecha-green/   # boot splash
├── install-login.sh        # installs both, requires root
└── uninstall-login.sh      # removes both, requires root
```

## Install

```sh
sudo ./system/install-login.sh
```

The installer backs up the current SDDM/Plymouth configuration to
`/var/backups/mecha-green-login-*`, installs both themes, selects the Plymouth
theme and rebuilds the initramfs.

- Login screen: applies on the next logout/reboot.
- Boot splash: applies on the next boot.
- Lock screen: no system install needed; it is themed by the active theme's
  `shell.toml` and uses the current topographic wallpaper with Omarchy's standard
  lock treatment.

## Preview

```sh
# Login screen (SDDM test mode, no logout)
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/mecha-green

# Lock screen over the current wallpaper
omarchy-shell lock preview
```

## Uninstall

```sh
sudo ./system/uninstall-login.sh
```

It restores the Omarchy Plymouth theme and removes the Mecha Green SDDM
theme/config. A custom SDDM config can be restored from the backup directory.
