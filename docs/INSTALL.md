# Install

## Requirements

- Omarchy with Hyprland and the Omarchy shell (Quickshell).
- `git` or `curl` for the installer.
- `ping` (`iputils`) for Mecha HUD / Mecha NET.
- ImageMagick (`magick`) only for the optional Halo wallpaper fetcher.
- `ffmpeg` for local live wallpaper generation (already present on Omarchy).

The installer does not use `sudo`. It writes to:

```
~/.config/omarchy/themes/mecha-green
~/.config/omarchy/themes/mecha-green-light
~/.config/omarchy/plugins/sazardev.mecha-hud
~/.config/omarchy/plugins/sazardev.ping
~/.local/bin/mecha-status
~/.local/bin/ping-status
~/.local/bin/mecha-fetch-halo
~/.local/bin/mecha-livewall
~/.local/bin/mecha-live-next
~/.local/bin/mecha-live-set
~/.local/share/omarchy-mecha-green
```

## Full setup (one command)

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sazardev/omarchy-mecha-green/main/install.sh)"
```

The script fetches the repository to a temporary directory, installs both
themes and both plugins, enables the Mecha HUD on the right of the bar, and
applies the dark theme.

## From a clone

```sh
git clone https://github.com/sazardev/omarchy-mecha-green.git
cd omarchy-mecha-green
./install.sh
```

### Examples

```sh
./install.sh --light                 # apply the light theme
./install.sh --halo                  # fetch the full optional Halo & military set
./install.sh --halo-live             # fetch it and build the live loops
./install.sh --ping                  # also enable the standalone NET widget
./install.sh --no-hud                # themes only
./install.sh --bar glassy            # translucent bar instead of opaque
./install.sh --no-bar                # keep the current bar mode
./install.sh --dry-run               # inspect without changing anything
```

## Manual install

If you prefer to copy things yourself:

```sh
# Themes
mkdir -p ~/.config/omarchy/themes
cp -r themes/mecha-green themes/mecha-green-light ~/.config/omarchy/themes/

# Plugins
mkdir -p ~/.config/omarchy/plugins
cp -r plugins/sazardev.mecha-hud plugins/sazardev.ping ~/.config/omarchy/plugins/

# CLI
mkdir -p ~/.local/bin
cp scripts/mecha-status scripts/ping-status scripts/mecha-themetize \
  scripts/mecha-livewall scripts/mecha-live-next ~/.local/bin/
chmod +x ~/.local/bin/mecha-status ~/.local/bin/ping-status ~/.local/bin/mecha-themetize \
  ~/.local/bin/mecha-livewall ~/.local/bin/mecha-live-next

# Optional Halo & military wallpapers
mkdir -p ~/.local/share/omarchy-mecha-green/{scripts,assets}
cp scripts/fetch-halo-backgrounds.sh scripts/mecha-livewall scripts/make-live-set.sh \
  ~/.local/share/omarchy-mecha-green/scripts/
cp assets/lut-*.png ~/.local/share/omarchy-mecha-green/assets/
cp -R assets/live ~/.local/share/omarchy-mecha-green/assets/
chmod +x ~/.local/share/omarchy-mecha-green/scripts/fetch-halo-backgrounds.sh \
  ~/.local/share/omarchy-mecha-green/scripts/mecha-livewall \
  ~/.local/share/omarchy-mecha-green/scripts/make-live-set.sh
ln -sf ~/.local/share/omarchy-mecha-green/scripts/fetch-halo-backgrounds.sh ~/.local/bin/mecha-fetch-halo
ln -sf ~/.local/share/omarchy-mecha-green/scripts/make-live-set.sh ~/.local/bin/mecha-live-set

# Fetch only some curated sets (spartans, unsc, covenant, forerunner)
mecha-fetch-halo --set spartans,unsc
mecha-fetch-halo --list-sets

# Build the Halo live loops, then cycle only videos
mecha-live-set
mecha-live-next

# Load and apply
omarchy-shell shell rescanPlugins
omarchy theme set "Mecha Green"
omarchy plugin enable sazardev.mecha-hud --section right --after omarchy.power
```

## Login and boot screen (optional, root)

The SDDM login theme and Plymouth boot splash are system files, so they are
installed separately from the user themes:

```sh
sudo ./system/install-login.sh
```

What it does:

- Backs up `/etc/plymouth/plymouthd.conf` and `/etc/sddm.conf.d` to
  `/var/backups/mecha-green-login-*`.
- Copies the SDDM theme to `/usr/share/sddm/themes/mecha-green` and writes
  `/etc/sddm.conf.d/99-zz-mecha-green.conf` (`Current=mecha-green`).
- Copies the Plymouth theme to
  `/usr/share/plymouth/themes/mecha-green`.
- Selects it with `plymouth-set-default-theme mecha-green` and rebuilds the
  initramfs (`limine-mkinitcpio` or `mkinitcpio -P`).

The SDDM theme appears on the next logout/reboot; the splash on the next boot.

Preview the login theme without logging out:

```sh
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/mecha-green
```

Preview the lock screen over the current wallpaper:

```sh
omarchy-shell lock preview
```

Click anywhere to dismiss the lock preview.

Undo:

```sh
sudo ./system/uninstall-login.sh
```

## Standard Omarchy theme install

The themes are also published as standalone, registry-ready repositories with
`colors.toml`, `backgrounds/` and `preview.png` at the root:

```sh
# Once listed in the Omarchy registry
omarchy theme install mecha-green
omarchy theme install mecha-green-light

# Direct from the theme repositories, available now
omarchy theme install https://github.com/sazardev/omarchy-mecha-green-theme
omarchy theme install https://github.com/sazardev/omarchy-mecha-green-light-theme
```

This is the safest and most standard path. It keeps the palette, `shell.toml`,
btop, Chromium, icons, keyboard RGB, unlock art and the eight bundled
wallpapers. Omarchy deliberately drops `.lua` files and terminal configs from
repository-installed themes and regenerates them from `colors.toml`, so the
marketplace theme cannot run code on your machine.

Use `install.sh` below when you also want the Mecha HUD, Mecha NET, the CLIs,
both themes at once, the optional Halo sets and the SDDM/Plymouth login
screens. The full installer copies the theme folders as **user-owned** themes,
where the custom `hyprland.lua` and Alacritty config are allowed.

## Use the built-in command module

If you prefer not to install a plugin, `ping-status` works with Omarchy's
built-in command widget. Add this to `~/.config/omarchy/shell.json` under
`bar.layout.right` (or another section):

```json
{
  "id": "ping",
  "type": "command",
  "exec": "~/.local/bin/ping-status 1.1.1.1",
  "interval": 5,
  "tooltip": "Ping"
}
```

The script prints Waybar-style JSON:

```json
{"text":"044 ms","tooltip":"NET 44 ms · 1.1.1.1","class":"good"}
```

## Troubleshooting

**The HUD is not on the bar.**
```sh
omarchy plugin list | grep mecha
omarchy-shell shell rescanPlugins
omarchy plugin enable sazardev.mecha-hud --section right --after omarchy.power
```

**The plugin reports an error.**
```sh
journalctl -t omarchy-shell --no-pager -n 80
```
QML plugin changes hot-reload, but a full `omarchy restart shell` is the
cleanest way to clear a stale QML cache after editing plugin files.

**The bar is still transparent.**
```sh
omarchy bar background opaque
```
`shell.toml` supplies the bar colour; the bar background mode decides whether
that colour is painted.

**Ping shows `--`.**
Check that `ping -c 1 1.1.1.1` works in a terminal. Some networks block ICMP;
switch the HUD to the `GATEWAY` target in the panel or set `pingHost` to a host
you can reach.

**`--halo` stops at ImageMagick.**
Install it with `omarchy pkg add imagemagick`, then run `mecha-fetch-halo`.

## Uninstall

```sh
./uninstall.sh
```

Switch to another theme first:
```sh
omarchy theme set "Temerald"
```
