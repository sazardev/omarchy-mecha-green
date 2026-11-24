# Wallpapers

Mecha Green ships with original artwork and an optional, separately fetched
Halo & military set. This split keeps the repository's MIT license clean while
still letting you get the full Master Chief desktop in one command.

## Bundled default (MIT)

Each theme includes one 2560×1440 flat wallpaper:

| Theme | File | Art |
|---|---|---|
| Dark | `0-topographic.webp` | Flowing olive contour waves and Geist typography on `#0E1009` |
| Light | `0-topographic-light.webp` | Flowing olive contour waves and Geist typography on `#E9E5CB` |

The `0-` prefix keeps the brand wallpaper first alphabetically, even when
optional or personal backgrounds are installed. No live loops are bundled.

SVG sources live in [`../assets/svg/`](../assets/svg/). Regenerate the wallpapers
and previews with `./scripts/render-wallpapers.sh`. The Halo & military fetch and
live set remain optional; see [`LIVE_WALLPAPERS.md`](LIVE_WALLPAPERS.md) for
playback, controls and the `mecha-livewall` generator.

## Optional Halo & military set (personal use only)

The optional images are fan / © Microsoft–343 Industries / third-party
artwork. They are **not** included in this repository and are **not** covered
by the MIT license. The fetcher downloads them from Wallhaven and grades them
to the Mecha Green palette. Use them for your own desktop only; do not
redistribute them.

The set is deliberately curated to olive, amber and cream. Blue-heavy scenes
are pushed through the same `mecha-themetize` filter used by the CLI. The
optional fetch now includes four extra curated sets:

| Set | Files | Content |
|---|---:|---|
| Spartans | 5 dark / 5 light | Chief and Spartan portraits |
| UNSC | 5 dark / 5 light | Frigates, city, ODSTs, Pelican and Warthog |
| Covenant | 5 dark / 5 light | Elites, Arbiter and energy swords |
| Forerunner | 6 dark / 6 light | Spires, rings, temple and ring horizons |

```sh
mecha-fetch-halo
# or, from a clone:
./scripts/fetch-halo-backgrounds.sh

# Only some sets
mecha-fetch-halo --set spartans,unsc
./scripts/fetch-halo-backgrounds.sh --set covenant

# List the sets
mecha-fetch-halo --list-sets
```

Requirements: `curl`, ImageMagick (`magick`) and `ffmpeg` for the live set.
Existing files are kept unless you pass `--force`; use `--force` after
upgrading to refresh the new set. Use `--dark-only` or `--light-only` to limit
the download.

Together the base and curated sets add **34 dark** and **30 light** stills.

### Base dark set (13)

| File | Wallhaven | Uploader |
|---|---|---|
| `1-master-chief.webp` | [85qdg2](https://wallhaven.cc/w/85qdg2) | NonoRiri |
| `2-amber-chief.webp` | [4x7leo](https://wallhaven.cc/w/4x7leo) | JT42 |
| `3-chief-dark.webp` | [3lovdd](https://wallhaven.cc/w/3lovdd) | SnackySkullFace |
| `4-night-ring.webp` | [9odk5d](https://wallhaven.cc/w/9odk5d) | ArtificialCC |
| `5-warthog.webp` | [5dy1j8](https://wallhaven.cc/w/5dy1j8) | CrisMaggot |
| `6-fireteam.webp` | [eo8ggr](https://wallhaven.cc/w/eo8ggr) | ZuaDoR0 |
| `7-canyon.webp` | [5wwdz7](https://wallhaven.cc/w/5wwdz7) | nativepixel |
| `16-halo-dawn.webp` | [e725e8](https://wallhaven.cc/w/e725e8) | ebullientprism |
| `17-forerunner-gate.webp` | [j5o29p](https://wallhaven.cc/w/j5o29p) | SamUerto |
| `18-warthog-canyon.webp` | [wyrz9q](https://wallhaven.cc/w/wyrz9q) | SamUerto |
| `19-tank-dust.webp` | [0jwrjy](https://wallhaven.cc/w/0jwrjy) | Wallhaven |
| `20-helicopter-sunset.webp` | [4lxrdp](https://wallhaven.cc/w/4lxrdp) | br3athless |
| `21-jet-night.webp` | [42vrp6](https://wallhaven.cc/w/42vrp6) | Wallhaven |

### Base light set (9)

| File | Wallhaven | Uploader |
|---|---|---|
| `1-warthog-light.webp` | [5dy1j8](https://wallhaven.cc/w/5dy1j8) | CrisMaggot |
| `2-canyon-light.webp` | [5wwdz7](https://wallhaven.cc/w/5wwdz7) | nativepixel |
| `3-desert-light.webp` | [oxer87](https://wallhaven.cc/w/oxer87) | SamUerto |
| `4-jungle-light.webp` | [zmreeg](https://wallhaven.cc/w/zmreeg) | SamUerto |
| `16-halo-dawn.webp` | [e725e8](https://wallhaven.cc/w/e725e8) | ebullientprism |
| `17-forerunner-gate.webp` | [j5o29p](https://wallhaven.cc/w/j5o29p) | SamUerto |
| `18-warthog-canyon.webp` | [wyrz9q](https://wallhaven.cc/w/wyrz9q) | SamUerto |
| `19-tank-dust.webp` | [0jwrjy](https://wallhaven.cc/w/0jwrjy) | Wallhaven |
| `20-helicopter-snow.webp` | [nmkkq1](https://wallhaven.cc/w/nmkkq1) | Wallhaven |

### Curated sets (21 dark / 21 light)

Dark files use 22–42. The light twin uses one number lower (21–41), so
`22-chief-noir.webp` becomes `21-chief-noir.webp` in the light theme.

| Set | Dark file | Light file | Wallhaven | Uploader |
|---|---|---|---|---|
| Spartans | `22-chief-noir.webp` | `21-chief-noir.webp` | [0je6vp](https://wallhaven.cc/w/0je6vp) | Wallhaven |
| Spartans | `23-chief-blue.webp` | `22-chief-blue.webp` | [6qjwel](https://wallhaven.cc/w/6qjwel) | ZuaDoR0 |
| Spartans | `24-helmet-amber.webp` | `23-helmet-amber.webp` | [83qpoy](https://wallhaven.cc/w/83qpoy) | Crossby |
| Spartans | `25-chief-rain.webp` | `24-chief-rain.webp` | [lq887r](https://wallhaven.cc/w/lq887r) | canadianakin |
| Spartans | `26-spartan-visor.webp` | `25-spartan-visor.webp` | [435686](https://wallhaven.cc/w/435686) | ShiftySigma |
| UNSC | `27-unsc-frigate.webp` | `26-unsc-frigate.webp` | [4537m8](https://wallhaven.cc/w/4537m8) | mattilius258 |
| UNSC | `28-unsc-city.webp` | `27-unsc-city.webp` | [g8le3e](https://wallhaven.cc/w/g8le3e) | SamUerto |
| UNSC | `29-odst-squad.webp` | `28-odst-squad.webp` | [lm7l9p](https://wallhaven.cc/w/lm7l9p) | SamUerto |
| UNSC | `30-pelican-drop.webp` | `29-pelican-drop.webp` | [oxep9p](https://wallhaven.cc/w/oxep9p) | SamUerto |
| UNSC | `31-warthog-sunset.webp` | `30-warthog-sunset.webp` | [vgj8z8](https://wallhaven.cc/w/vgj8z8) | DeltaPrime |
| Covenant | `32-elite-portrait.webp` | `31-elite-portrait.webp` | [4d3lrl](https://wallhaven.cc/w/4d3lrl) | JT42 |
| Covenant | `33-elite-night.webp` | `32-elite-night.webp` | [kw6qq7](https://wallhaven.cc/w/kw6qq7) | SamUerto |
| Covenant | `34-arbiter-duel.webp` | `33-arbiter-duel.webp` | [mdmkem](https://wallhaven.cc/w/mdmkem) | SamUerto |
| Covenant | `35-elite-closeup.webp` | `34-elite-closeup.webp` | [mpq2o1](https://wallhaven.cc/w/mpq2o1) | ZuaDoR0 |
| Covenant | `36-energy-swords.webp` | `35-energy-swords.webp` | [z8gmyo](https://wallhaven.cc/w/z8gmyo) | BIOOH |
| Forerunner | `37-forerunner-spire.webp` | `36-forerunner-spire.webp` | [39pgl3](https://wallhaven.cc/w/39pgl3) | Crossby |
| Forerunner | `38-ring-arc.webp` | `37-ring-arc.webp` | [dpvvgm](https://wallhaven.cc/w/dpvvgm) | Wallhaven |
| Forerunner | `39-forerunner-temple.webp` | `38-forerunner-temple.webp` | [ey1mll](https://wallhaven.cc/w/ey1mll) | SamUerto |
| Forerunner | `40-forerunner-snow.webp` | `39-forerunner-snow.webp` | [kwomm1](https://wallhaven.cc/w/kwomm1) | DeltaPrime |
| Forerunner | `41-chief-sunset.webp` | `40-chief-sunset.webp` | [l3o6yl](https://wallhaven.cc/w/l3o6yl) | Doctorc418 |
| Forerunner | `42-ring-horizon.webp` | `41-ring-horizon.webp` | [y8ldqd](https://wallhaven.cc/w/y8ldqd) | Doctorc418 |

### Live set (7 dark / 5 light)

`mecha-live-set` turns the fetched stills into animated H.264 loops:

```sh
mecha-fetch-halo
mecha-live-set
```

- Dark: UNSC city, Chief in rain, Covenant portrait, ring arc, Warthog dust,
  Forerunner spire and energy swords.
- Light: UNSC city, Chief in rain, Forerunner snow, Warthog dust and ring arc.

The loops live in `~/.config/omarchy/backgrounds/mecha-green{,-light}/` and are
played natively by OWE. `mecha-live-next` skips stills and cycles videos only.

The fetch script crops out the original site watermarks where present, resizes
to 2560×1440, applies an olive/amber grade (or a light grade for the light
theme), and writes WebP at quality 92. The original 1–7 / 1–4 set uses:

- [`assets/lut-olive-amber.png`](../assets/lut-olive-amber.png) for the
  night-ring and fireteam duotones.
- [`assets/lut-tritone.png`](../assets/lut-tritone.png) for the light desert and
  jungle duotones.
- [`assets/lut-hero.png`](../assets/lut-hero.png) plus a blue-channel mask for
  the warm-graded Master Chief field hero, so the original cyan beams and sky
  are replaced with olive/amber/cream.

The newer 16–21 / 16–20 and all four curated sets are processed with
[`mecha-themetize`](../scripts/mecha-themetize) at 80% strength, so they share
the same gradient-map palette as user wallpapers. The curated sets drop the
bottom 8% of each source first to remove publisher watermarks.

## Themetize your own

```sh
# Dark only, next to the input
mecha-themetize photo.jpg

# Both modes, installed into the themes with the next free number
mecha-themetize photo.jpg --mode both --install --name 22-photo

# Light only, keep more original colour
mecha-themetize art.png out.webp --mode light --keep-color 30
```

`--strength` controls how much of the theme grade is applied; `--keep-color`
is its inverse. `--fit` crops to 2560×1440 by default (`none` keeps the input
aspect), `--vignette` and `--grain` add optional texture.

## Themetize a video wallpaper

```sh
# Slow HUD push
mecha-livewall photo.jpg --style command --install

# Rain, both themes
mecha-livewall art.png --mode both --style rain --install --name my-wall

# Skip the filter for an already-graded image
mecha-livewall chief.webp --no-filter --style rain --install --name chief
```

Styles: `command`, `rain`, `dust`, `pulse`, `storm` and `radar`. Output is
2560×1440 H.264, 30 fps, silent and looped. `--install` writes to the current
theme's user background folder; `--set` applies it immediately.

## Add your own

```sh
# Fast path: auto-number and install into both themes
mecha-themetize my-wallpaper.jpg --mode both --install --name my-wallpaper

# Or copy a ready WebP yourself
cp my-wallpaper.webp ~/.config/omarchy/themes/mecha-green/backgrounds/22-my-wallpaper.webp
omarchy theme bg next
```

The image picker and `omarchy theme bg next` read the folder directly; no
restart is needed.

## Licensing summary

| Asset | License |
|---|---|
| Theme configuration (`*.toml`, `*.lua`, `btop.theme`, etc.) | MIT |
| Plugins and scripts | MIT |
| Original topographic wave art and SVGs | MIT |
| Halo & military wallpaper set and live loops | © Microsoft–343 Industries / respective Wallhaven uploaders; personal use only; not redistributed here |
| Omarchy logo (recoloured boot mark) | Omarchy project |

Halo, Master Chief, MCHOSE and Omarchy are trademarks of their respective
owners. This is a personal fan project.
