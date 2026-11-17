# Install

## Requirements

- Omarchy with Hyprland and the Omarchy shell (Quickshell).
- `git` or `curl` for the installer.
- `ping` (`iputils`) for Mecha HUD / Mecha NET.
- ImageMagick (`magick`) only for the optional Halo wallpaper fetcher.

The installer does not use `sudo`. It writes to:

```
~/.config/omarchy/themes/mecha-green
~/.config/omarchy/themes/mecha-green-light
~/.config/omarchy/plugins/sazardev.mecha-hud
~/.config/omarchy/plugins/sazardev.ping
~/.local/bin/mecha-status
~/.local/bin/ping-status
~/.local/bin/mecha-fetch-halo
~/.local/share/omarchy-mecha-green
```

## One command

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
./install.sh --halo                  # also fetch the optional Halo wallpapers
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
cp scripts/mecha-status scripts/ping-status ~/.local/bin/
chmod +x ~/.local/bin/mecha-status ~/.local/bin/ping-status

# Optional Halo wallpapers
mkdir -p ~/.local/share/omarchy-mecha-green/{scripts,assets}
cp scripts/fetch-halo-backgrounds.sh ~/.local/share/omarchy-mecha-green/scripts/
cp assets/lut-olive-amber.png ~/.local/share/omarchy-mecha-green/assets/
chmod +x ~/.local/share/omarchy-mecha-green/scripts/fetch-halo-backgrounds.sh
ln -sf ~/.local/share/omarchy-mecha-green/scripts/fetch-halo-backgrounds.sh ~/.local/bin/mecha-fetch-halo

# Load and apply
omarchy-shell shell rescanPlugins
omarchy theme set "Mecha Green"
omarchy plugin enable sazardev.mecha-hud --section right --after omarchy.power
```

## Why not `omarchy theme install`?

`omarchy theme install <url>` is perfect for a single theme at the root of a
repository. This repository is a **collection**: two themes, two plugins, a
CLI, a fetcher and original SVG sources. Omarchy's repo-theme path also
deliberately drops `.lua` files and terminal configs from cloned themes
(`hyprland.lua`, `alacritty.toml`) because they can run code. Mecha Green uses
a custom `hyprland.lua` and Alacritty config, so the installer copies the theme
folders as **user-owned** themes, where those files are allowed. If you only
want the dark theme and no customization, you can still copy
`themes/mecha-green` into `~/.config/omarchy/themes/` yourself.

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
