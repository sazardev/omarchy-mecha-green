# Live wallpapers

Mecha Green uses Omarchy's native **OWE** renderer for video backgrounds. No
extra playback daemon is required: a video placed in a theme's `backgrounds/`
folder shows up in the normal Omarchy background picker and plays with hardware
decoding.

Six original live loops are bundled with each theme. They are silent,
2560×1440 H.264 at 24 fps, 8 seconds long and loop seamlessly. Only the contour
lines undulate; the Geist wordmark remains fixed.

| Loop | Dark | Light |
|---|---|---|
| Drift | `100-drift.mp4` | `100-drift-light.mp4` |
| Fold | `101-fold.mp4` | `101-fold-light.mp4` |
| Field | `102-field.mp4` | `102-field-light.mp4` |
| Terrain | `103-terrain.mp4` | `103-terrain-light.mp4` |
| Panorama | `104-panorama.mp4` | `104-panorama-light.mp4` |
| Undulate | `105-undulate.mp4` | `105-undulate-light.mp4` |

They appear in the Mecha HUD's **NEXT LIVE** button, which skips stills and
cycles only videos. Regenerate them with
`python3 proposals/backgrounds/generate-live.py`.

Videos created with `mecha-livewall` or the Halo set remain optional and use the
same native OWE playback path.

## Halo live set

The optional Halo stills can be turned into a curated live set. Fetch the
stills first, then build the loops:

```sh
./scripts/fetch-halo-backgrounds.sh
mecha-live-set
```

`mecha-live-set` builds **7 dark / 5 light** loops from the filtered stills:

| Theme | Loops |
|---|---|
| Dark | UNSC city, Chief in rain, Covenant portrait, ring arc, Warthog dust, Forerunner spire, energy swords |
| Light | UNSC city, Chief in rain, Forerunner snow, Warthog dust, ring arc |

They are written to
`~/.config/omarchy/backgrounds/mecha-green{,-light}/live-*.mp4`, so they survive
theme updates. Use `--dark-only`, `--light-only` or `--force` as needed.

The Halo artwork remains personal-use only and is not bundled in the repository.

## Themetize any image

`mecha-livewall` turns any still into a filtered live wallpaper:

```sh
# Command-feed push with scanlines and HUD frame
mecha-livewall photo.jpg --install

# Rain, both themes, auto-numbered
mecha-livewall art.png --mode both --style rain --install --name my-wall

# Already filtered (for example a fetched Halo still)
mecha-livewall chief.webp --no-filter --style rain --install --name chief
```

Styles:

| Style | Motion |
|---|---|
| `command` | Slow push, scanlines, HUD frame and grain |
| `rain` | Command plus falling rain |
| `dust` | Slow pan with drifting fog and dust |
| `pulse` | Slow push with an amber energy glow |
| `storm` | Rain with a subtle lightning flicker |
| `radar` | Rotating radar sweep, for HUD/radar art |

Options include `--mode dark|light|both`, `--duration`, `--fps`,
`--strength`, `--fit WxH`, `--install`, `--set` and `--force`. Input images go
through `mecha-themetize` by default; pass `--no-filter` when the image is
already graded.

The loop uses a sine-based camera move, so it returns to its first frame. Rain,
radar sweeps, fog and glow are timed to the same duration.

## Cycle videos only

```sh
mecha-live-next
```

Reads the current theme, finds its video backgrounds and sets the next one.
This is the command behind the HUD's `NEXT LIVE` button.

## Performance

- Bundled topographic loops: 2560×1440, 24 fps, H.264 High, no audio.
- Generated `mecha-livewall` loops: 2560×1440, 30 fps by default.
- OWE pauses video automatically when fullscreen or the monitor sleeps,
  depending on its policy.
- Keep individual loops under roughly 10 MB and avoid 4K sources for a 1080p
  desktop.
