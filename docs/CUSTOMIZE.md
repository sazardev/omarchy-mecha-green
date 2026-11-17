# Customize

## Palette

The source of truth is `themes/mecha-green/colors.toml` (and the light twin).
Change a value there and re-apply the theme so Omarchy regenerates terminals,
Neovim, VS Code, btop, tmux, gum, fcitx5 and the shell:

```sh
omarchy theme set "Mecha Green"
```

Useful keys:

| Key | Used by |
|---|---|
| `background`, `foreground` | shell, terminals, editors, btop |
| `accent` | bar indicators, selected text, window-border gradient, boot logo |
| `selection` / `selection_background` | selected rows and terminal selection |
| `green`, `yellow`, `orange` | btop meters, ANSI palette |
| `hyprland_active_border` | Hyprland window border gradient |
| `muted` | inactive/secondary text |

The original artwork uses the same palette: `#0E1009` / `#9DAE5C` / `#F2C84B`
for dark and `#E9E5CB` / `#4F6428` / `#7D5200` for light.

## Shell surfaces

`shell.toml` replaces Omarchy's generated shell file. The interesting sections:

- `[bar]` — `background`, `text`, `active`, `size-horizontal`,
  `size-vertical`.
- `[controls]` — normal/hover/focus/selected states.
- `[popups]`, `[notifications]`, `[menu]`, `[launcher]` — surfaces and borders.
- `[lock]`, `[polkit]` — lock screen and sudo/password cards.
- `[image-picker]` — wallpaper/browser-image carousel.

The Mecha Green files use 2 px gradient borders on popups and notifications,
28 px horizontal bars, amber selection and an opaque olive/sand appbar. The
bar itself must be in `opaque` or `glassy` mode to paint the colour:

```sh
omarchy bar background opaque
```

## Bar widgets

Add or move the HUD:

```sh
omarchy plugin enable sazardev.mecha-hud --section right --after omarchy.power
omarchy bar move sazardev.mecha-hud --section right --index 0
```

Change HUD settings:

```sh
omarchy bar set sazardev.mecha-hud pingHost 8.8.8.8
omarchy bar set sazardev.mecha-hud pingIntervalSec 5
omarchy bar set sazardev.mecha-hud showCpu true
```

Remove a widget from the bar by editing `~/.config/omarchy/shell.json` (the
shell hot-reloads), or disable the plugin:

```sh
omarchy plugin disable sazardev.ping
```

## Wallpapers

Add any image to:

```sh
~/.config/omarchy/themes/mecha-green/backgrounds/
~/.config/omarchy/themes/mecha-green-light/backgrounds/
```

Files are sorted alphabetically. The bundled originals use `8-`, `9-` and
`10-` prefixes so the optional Halo set (`1-` to `7-`) can sit in front. Cycle
with:

```sh
omarchy theme bg next
```

## Boot logo

`unlock.png` is the Plymouth boot logo, `preview-unlock.png` is the switcher
preview. The amber/dark-bronze versions were generated from the Omarchy logo.
Replace them with your own 800×188 transparent PNG and 1920×1080 preview.

## Icons

`icons.theme` contains a single icon-theme name. Both variants use
`Yaru-olive`; change it and re-apply the theme.

## Terminals

The dark theme ships a custom `alacritty.toml` with an amber cursor and olive
selection. Kitty, Foot and Ghostty are generated from `colors.toml`. If you use
one of those, edit the generated file after applying or add a custom theme file
next to `alacritty.toml`.

## Make your own variant

1. Copy `themes/mecha-green` to a new folder under
   `~/.config/omarchy/themes/`.
2. Change `colors.toml` and, if needed, `shell.toml`.
3. Copy/replace the backgrounds and preview.
4. `omarchy theme set "<new folder name>"`.

Keep the theme folder free of `.git` if you want Omarchy to treat it as a
user-owned theme (so Lua/terminal files are allowed). A cloned theme is held
to Omarchy's stricter repo-theme file rules.
