# Wallpaper quality

Last verified: 2026-11-25.

The bundled wallpapers are rendered directly from their SVG sources. No raster
image is enlarged to 4K. The twelve live loops are generated from the same
vector layers at 3840×2160 and 60 fps before H.264 encoding. All 480 frames
are rendered independently; the previous 24 fps files are not interpolated.

## Stills

| Check | Result |
|---|---|
| Source | Original SVG, unchanged composition |
| Output | 3840×2160 |
| Format | Lossless WebP (VP8L) |
| 4K error vs direct SVG render | 0.000000 normalized RMSE |
| 1080p error vs direct SVG render | 0.006104 average |
| Previous 1440p files at 1080p | 0.008286 average |

At a 1080p display size, downscaling the new 4K lossless stills is about 26%
closer to a direct SVG render than the previous 1440p lossy WebP files. On a 4K
display, the new files are pixel-identical to the vector render and avoid the
upscaling artifacts of the old collection.

Reproduce the still comparison with the sources in `assets/svg/` and
`proposals/backgrounds/svg/`:

```sh
rsvg-convert --width 3840 --height 2160 SOURCE.svg --output reference.png
magick themes/mecha-green/backgrounds/100-drift.webp reference.png \
  -metric RMSE -compare -format '%[distortion]\n' info:
```

## Live loops

| Check | Bundled loops |
|---|---|
| Resolution | 3840×2160 |
| Codec | H.264 High, level 5.1 |
| Pixel format | yuv420p |
| Colour | BT.709 limited range |
| Frame rate | 60 fps |
| Duration | 8 seconds / 480 frames |
| Encoder | NVIDIA NVENC H.264, p7 high quality, CQ 18 |
| Bitrate | 20.8–45.0 Mbps |
| Previous 1440p bitrate | 2.3–9.2 Mbps |

A frame-by-frame inspection of the dense Field loop shows continuous contour
lines without block noise at 1080p and only normal H.264 edge softening at 1:1
on a 4K display. The web previews use a 1920×1080, 60 fps NVENC CQ 19 cut at
7.6–14.7 Mbps. The downloadable Omarchy assets remain the native 4K files.

The final loops are encoded with NVENC on the RTX 2060 SUPER. The vector
displacement filters still run in FFmpeg on the CPU; only the video encoding is
offloaded to the GPU. Optimising the displacement maps to single rows/columns
reduced a loop from about 2m43s to 38s on the development machine.

## Active Omarchy snapshot

`omarchy theme update` only pulls the theme repository. Reapply the theme so
Omarchy refreshes `~/.local/state/omarchy/current/theme` and updates the active
background symlink:

```sh
omarchy theme update
omarchy theme set "Mecha Green"
omarchy theme bg cache
```

Verify the active file:

```sh
file "$(readlink -f ~/.local/state/omarchy/current/background)"
```
