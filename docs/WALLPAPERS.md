# Wallpapers

Mecha Green ships with original artwork and an optional, separately fetched
Halo set. This split keeps the repository's MIT license clean while still
letting you get the full Master Chief desktop in one command.

## Bundled originals (MIT)

Each theme includes three 2560×1440 originals:

| File | Art |
|---|---|
| `8-mecha-helmet.webp` | Geometric Spartan helmet, amber visor, HUD rings |
| `9-topographic.webp` | Olive contour map with an amber targeting reticle |
| `10-keyboard.webp` | Stylised MCHOSE Ace 75-style board with amber legends |

The light theme has the same three in sand/olive/bronze:
`8-mecha-helmet-light.webp`, `9-topographic-light.webp`,
`10-keyboard-light.webp`.

SVG sources live in [`../assets/svg/`](../assets/svg/). They are also MIT.

These are the wallpapers a fresh install has. The theme works out of the box
with them; the Halo fetch is optional.

## Optional Halo set (personal use only)

The Halo images are fan / © Microsoft–343 Industries artwork. They are **not**
included in this repository and are **not** covered by the MIT license. The
fetcher downloads them from Wallhaven and grades them to the Mecha Green
palette. Use them for your own desktop only; do not redistribute them.

```sh
mecha-fetch-halo
# or, from a clone:
./scripts/fetch-halo-backgrounds.sh
```

Requirements: `curl` and ImageMagick (`magick`). Existing files are kept unless
you pass `--force`. Use `--dark-only` or `--light-only` to limit the download.

### Dark set

| File | Wallhaven | Uploader |
|---|---|---|
| `1-master-chief.webp` | [85qdg2](https://wallhaven.cc/w/85qdg2) | NonoRiri |
| `2-amber-chief.webp` | [4x7leo](https://wallhaven.cc/w/4x7leo) | JT42 |
| `3-chief-dark.webp` | [3lovdd](https://wallhaven.cc/w/3lovdd) | SnackySkullFace |
| `4-night-ring.webp` | [9odk5d](https://wallhaven.cc/w/9odk5d) | ArtificialCC |
| `5-forerunner-gate.webp` | [j5o29p](https://wallhaven.cc/w/j5o29p) | SamUerto |
| `6-fireteam.webp` | [eo8ggr](https://wallhaven.cc/w/eo8ggr) | ZuaDoR0 |
| `7-canyon.webp` | [5wwdz7](https://wallhaven.cc/w/5wwdz7) | nativepixel |

### Light set

| File | Wallhaven | Uploader |
|---|---|---|
| `1-dawn-ring.webp` | [e725e8](https://wallhaven.cc/w/e725e8) | ebullientprism |
| `2-field-light.webp` | [85qdg2](https://wallhaven.cc/w/85qdg2) | NonoRiri |
| `3-canyon-light.webp` | [5wwdz7](https://wallhaven.cc/w/5wwdz7) | nativepixel |

The fetch script crops out the original site watermarks where present, resizes
to 2560×1440, applies an olive/amber grade (or a light grade for the light
theme), and writes WebP at quality 92. It uses the local
[`assets/lut-olive-amber.png`](../assets/lut-olive-amber.png) LUT for the
night-ring and fireteam duotones.

## Add your own

```sh
cp my-wallpaper.webp ~/.config/omarchy/themes/mecha-green/backgrounds/11-my-wallpaper.webp
omarchy theme bg next
```

The image picker and `omarchy theme bg next` read the folder directly; no
restart is needed.

## Licensing summary

| Asset | License |
|---|---|
| Theme configuration (`*.toml`, `*.lua`, `btop.theme`, etc.) | MIT |
| Plugins and scripts | MIT |
| Original helmet/topographic/keyboard art and SVGs | MIT |
| Halo wallpaper set | © Microsoft–343 Industries / respective Wallhaven uploaders; personal use only; not redistributed here |
| Omarchy logo (recoloured boot mark) | Omarchy project |

Halo, Master Chief, MCHOSE and Omarchy are trademarks of their respective
owners. This is a personal fan project.
