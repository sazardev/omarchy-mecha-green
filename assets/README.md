# Original art sources

The SVGs here are the sources for the bundled Mecha Green wallpapers:

| SVG | Rendered wallpaper |
|---|---|
| `helmet-dark.svg` | `themes/mecha-green/backgrounds/8-mecha-helmet.webp` |
| `helmet-light.svg` | `themes/mecha-green-light/backgrounds/8-mecha-helmet-light.webp` |
| `topo-dark.svg` | `themes/mecha-green/backgrounds/9-topographic.webp` |
| `topo-light.svg` | `themes/mecha-green-light/backgrounds/9-topographic-light.webp` |
| `keyboard-dark.svg` | `themes/mecha-green/backgrounds/10-keyboard.webp` |
| `keyboard-light.svg` | `themes/mecha-green-light/backgrounds/10-keyboard-light.webp` |

They are original geometric / HUD illustrations, MIT licensed with the rest of
the theme. Render them with:

```sh
rsvg-convert -w 2560 -h 1440 assets/svg/helmet-dark.svg -o /tmp/helmet.png
```

`lut-olive-amber.png` is the 256×1 colour lookup table used by the optional
Halo fetcher for the olive/amber duotones. It is also MIT.
