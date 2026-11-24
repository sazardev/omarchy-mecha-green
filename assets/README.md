# Original art sources

The bundled Mecha Green wallpaper is an original flat vector illustration,
MIT licensed with the rest of the theme.

| SVG | Rendered wallpaper |
|---|---|
| `topo-dark.svg` | `themes/mecha-green/backgrounds/0-topographic.webp` |
| `topo-light.svg` | `themes/mecha-green-light/backgrounds/0-topographic-light.webp` |

Regenerate the wallpapers and theme previews with:

```sh
./scripts/render-wallpapers.sh
```

The script requires `rsvg-convert` and ImageMagick (`magick`). It renders at
3840×2160 with lossless WebP, then derives the 1200×675 theme previews.

The six additional topographic designs live in
[`../proposals/backgrounds/svg/`](../proposals/backgrounds/svg/). Their stills
and live loops are bundled under the `100-` series in both themes.

The SDDM and Plymouth screens reuse the same dark SVG. Regenerate their
backgrounds and documentation previews with:

```sh
./scripts/render-system-assets.sh
```

## LUTs

The optional Halo fetcher uses three 256×1 colour lookup tables:

| File | Used for |
|---|---|
| `lut-olive-amber.png` | Night-ring and fireteam duotones |
| `lut-tritone.png` | Desert and jungle light duotones |
| `lut-hero.png` | The warm-graded Master Chief field hero |

All are original, MIT licensed.
