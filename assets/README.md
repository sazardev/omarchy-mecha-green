# Original art sources

These SVGs are the sources for the bundled Mecha Green wallpapers. They are
original geometric / HUD illustrations, MIT licensed with the rest of the
theme.

| SVG | Rendered wallpaper |
|---|---|
| `helmet-dark.svg` / `helmet-light.svg` | `8-mecha-helmet*.webp` |
| `topo-dark.svg` / `topo-light.svg` | `9-topographic*.webp` |
| `keyboard-dark.svg` / `keyboard-light.svg` | `10-keyboard*.webp` |
| `switch-blueprint-dark.svg` / `switch-blueprint-light.svg` | `11-switch-blueprint*.webp` |
| `pcb-blueprint-dark.svg` / `pcb-blueprint-light.svg` | `12-pcb-blueprint*.webp` |
| `radar-dark.svg` / `radar-light.svg` | `13-radar*.webp` |
| `helmet-blueprint-dark.svg` / `helmet-blueprint-light.svg` | `14-helmet-blueprint*.webp` |
| `crate-dark.svg` / `crate-light.svg` | `15-crate*.webp` |

Render one with:

```sh
rsvg-convert -w 2560 -h 1440 assets/svg/switch-blueprint-dark.svg -o /tmp/switch.png
magick /tmp/switch.png -quality 92 /tmp/switch.webp
```

## LUTs

The optional Halo fetcher uses three 256×1 colour lookup tables:

| File | Used for |
|---|---|
| `lut-olive-amber.png` | Night-ring and fireteam duotones |
| `lut-tritone.png` | Desert and jungle light duotones |
| `lut-hero.png` | The warm-graded Master Chief field hero |

All are original, MIT licensed.
