# Mecha Green Light

Sand, olive ink and bronze. The daylight half of the Mecha Green pair.

## Palette

| Role | Hex |
|---|---|
| Sand background | `#E9E5CB` |
| Raised surface | `#F1EEDA` |
| Olive | `#4F6428` |
| Bronze / accent | `#7D5200` |
| Dark olive ink | `#2B321A` |
| Rust | `#9C3F2D` |
| Deep patina | `#2F6A5E` |

## Included

- `colors.toml` — the full light palette; generates terminals, Neovim, VS Code,
  btop, tmux, gum, fcitx5 and the shell.
- `shell.toml` — sand appbar, bronze indicators, gradient borders, light menus,
  launcher and lock screen.
- `hyprland.lua` — bronze → olive → bronze 45° window border.
- `alacritty.toml` — bronze cursor, pale olive selection.
- `btop.theme`, `icons.theme` (`Yaru-olive`), `chromium.theme`,
  `keyboard.rgb`.
- `unlock.png` and `preview-unlock.png` — bronze Omarchy boot logo on sand.
- `backgrounds/` — seven flat topographic stills and six clean live loops:
  `0-topographic-light` is the default, followed by the collision-free `100-`
  series (Drift, Fold, Field, Terrain, Panorama and Undulate).

The optional light Halo & military wallpaper sets are fetched separately and
are not part of the MIT assets: 34 dark / 30 light files across Spartans, UNSC,
Covenant and Forerunner sets. Run `mecha-fetch-halo`, or limit it with
`mecha-fetch-halo --set spartans,unsc`; `--list-sets` shows the groups. Build
the 7 dark / 5 light Halo live loops with `mecha-live-set`.

## Apply

```sh
omarchy theme set "Mecha Green Light"
omarchy theme bg next
```

## Standard Omarchy install

The registry-ready light theme lives at
[`sazardev/omarchy-mecha-green-light-theme`](https://github.com/sazardev/omarchy-mecha-green-light-theme).
Install it directly:

```sh
omarchy theme install https://github.com/sazardev/omarchy-mecha-green-light-theme
```

Once the registry listing is live, `omarchy theme install mecha-green-light`
is the short form.

## Login and boot screens (optional)

```sh
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/sazardev/omarchy-mecha-green/main/system/install-login.sh)"
```

Installs the flat SDDM login and Plymouth splash, backs up the current
configuration and rebuilds the initramfs.
