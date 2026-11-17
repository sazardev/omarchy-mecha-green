# Mecha Green — dark

Olive drab, worn steel and Master Chief's amber visor.

This is the dark half of the Mecha Green pair. The light twin is
**Mecha Green Light**.

## Palette

| Role | Hex |
|---|---|
| Background | `#0E1009` |
| Raised surface | `#11150B` |
| Military olive | `#9DAE5C` |
| Visor amber / accent | `#F2C84B` |
| Sand text | `#D8D9B4` |
| Sage | `#BCC09A` |
| Rust | `#C85B47` |
| HUD teal | `#7FA89A` |

## Included

- `colors.toml` — the full dark palette; generates terminals, Neovim, VS Code,
  btop, tmux, gum, fcitx5 and the shell.
- `shell.toml` — olive-black appbar, amber indicators, gradient borders,
  amber-tinted menus/launcher/lock, 28 px bar.
- `hyprland.lua` — amber → olive → amber 45° window border.
- `alacritty.toml` — amber cursor, olive selection.
- `btop.theme`, `icons.theme` (`Yaru-olive`), `chromium.theme`,
  `keyboard.rgb`.
- `unlock.png` and `preview-unlock.png` — amber Omarchy boot logo.
- `backgrounds/` — eight original Mecha Green wallpapers: helmet,
  topographic HUD, keyboard, Hall Effect switch blueprint, PCB blueprint,
  tactical radar, helmet schematic and supply crate.

The optional Halo & military wallpaper sets are fetched separately and are not
part of the MIT assets: 34 dark / 30 light files across Spartans, UNSC,
Covenant and Forerunner sets. Run `mecha-fetch-halo`, or limit it with
`mecha-fetch-halo --set spartans,unsc`; `--list-sets` shows the groups.

## Apply

```sh
omarchy theme set "Mecha Green"
omarchy theme bg next
```
