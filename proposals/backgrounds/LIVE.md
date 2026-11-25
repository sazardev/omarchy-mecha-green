# Topographic Live Wallpapers

Cada una de las seis propuestas tiene una versión animada en oscuro y claro.

- 12 archivos MP4 en `live/`.
- 3840×2160 (4K nativo), 60 fps, 8 segundos, H.264 High, BT.709, sin audio.
- 480 frames renderizados desde los SVG; sin interpolación de los 24 fps anteriores.
- Renderizado directamente desde los SVG originales, sin escalar ni cambiar el fondo.
- Solo las curvas se deforman; el wordmark permanece fijo.
- Sin ruido, scanlines, HUD, glow, gradientes ni sombras.
- Loop senoidal continuo.

Abre [`live.html`](live.html) para ver la galería animada.

## Regenerar

```sh
python3 generate-live.py --install
```

El generador usa NVENC automáticamente cuando hay una GPU NVIDIA compatible y
cae a x264 en caso contrario. Un solo loop:

```sh
python3 generate-live.py --only 01-drift-dark --encoder nvenc
```

Requiere `rsvg-convert`, FFmpeg y las fuentes Geist.
