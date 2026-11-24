# Topographic Live Wallpapers

Cada una de las seis propuestas tiene una versión animada en oscuro y claro.

- 12 archivos MP4 en `live/`.
- 2560×1440, 24 fps, 8 segundos, H.264 High, sin audio.
- Solo las curvas se deforman; el wordmark permanece fijo.
- Sin ruido, scanlines, HUD, glow, gradientes ni sombras.
- Loop senoidal continuo.

Abre [`live.html`](live.html) para ver la galería animada.

## Regenerar

```sh
python3 generate-live.py
```

Una sola propuesta:

```sh
python3 generate-live.py --only 01-drift-dark
```

Requiere `rsvg-convert`, ImageMagick/FFmpeg y las fuentes Geist.
