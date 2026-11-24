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

## Wallpapers with the theme filter

`mecha-themetize` maps any image onto the theme palette with a luminance
gradient map, then blends back a configurable amount of the original colour:

```sh
# One dark WebP next to the input
mecha-themetize photo.jpg

# Both themes, auto-numbered and installed
mecha-themetize photo.jpg --mode both --install --name photo

# Light theme, 70% theme / 30% original
mecha-themetize photo.jpg --mode light --keep-color 30

# Keep the original composition, no 16:9 crop
mecha-themetize photo.jpg --fit none
```

Useful flags: `--strength` (0–100), `--keep-color` (0–100, inverse of strength),
`--fit WxH|none`, `--vignette`, `--grain`, `--force`.

## Live wallpapers

`mecha-livewall` turns a still into a filtered video loop:

```sh
mecha-livewall photo.jpg --style command --install
mecha-livewall art.png --mode both --style rain --install --name my-wall
```

Styles: `command`, `rain`, `dust`, `pulse`, `storm`, `radar`. The output is
2560×1440 H.264, 30 fps, silent and looped. `--install` writes to
`~/.config/omarchy/backgrounds/<theme>/`, and `mecha-live-next` cycles videos
only. No live loops are bundled with the theme; see
[`LIVE_WALLPAPERS.md`](LIVE_WALLPAPERS.md) for the optional Halo set.

## Wallpapers

Add any image to:

```sh
~/.config/omarchy/themes/mecha-green/backgrounds/
~/.config/omarchy/themes/mecha-green-light/backgrounds/
```

Files are sorted alphabetically. The default wallpaper uses the `0-` prefix so
it stays first even when optional or personal wallpapers are installed. Cycle
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

## Lock, login and boot screens

- **Lock screen:** edit the `[lock]` section of the theme's `shell.toml`
  (`background`, `text`, `placeholder`, `text-error`, `border`, `selection`).
  It follows the current wallpaper, so `omarchy theme bg next` changes the
  blurred backdrop too.
- **SDDM login:** edit `system/sddm/mecha-green/`. The background source is
  `background.svg` (render it to `background.webp`); `Main.qml` holds the
  logo, user selector, password field and error state; `entry.png`,
  `lock.png` and `bullet.png` are the amber/olive assets.
- **Plymouth boot:** edit `system/plymouth/mecha-green/`. `mecha-green.script`
  sets the background colour and progress animation; `logo.png`,
  `progress_bar.png` and `progress_box.png` are the visuals.

After changing system screens, reinstall them:

```sh
sudo ./system/install-login.sh
```

The SDDM theme applies on the next logout/reboot; Plymouth on the next boot.

## Make your own variant

1. Copy `themes/mecha-green` to a new folder under
   `~/.config/omarchy/themes/`.
2. Change `colors.toml` and, if needed, `shell.toml`.
3. Copy/replace the backgrounds and preview.
4. `omarchy theme set "<new folder name>"`.

Keep the theme folder free of `.git` if you want Omarchy to treat it as a
user-owned theme (so Lua/terminal files are allowed). A cloned theme is held
to Omarchy's stricter repo-theme file rules.
