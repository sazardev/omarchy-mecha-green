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
- `backgrounds/` — eight original light wallpapers: helmet, topographic HUD,
  keyboard, Hall Effect switch blueprint, PCB blueprint, tactical radar,
  helmet schematic and supply crate.

The optional light Halo & military wallpaper set is fetched separately and is not part of
the MIT assets. Run `mecha-fetch-halo` from the repository root or the
installer's `--halo` flag.

## Apply

```sh
omarchy theme set "Mecha Green Light"
omarchy theme bg next
```
