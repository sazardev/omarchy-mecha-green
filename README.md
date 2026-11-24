# Mecha Green for Omarchy

**A flat topographic theme for Omarchy, with dark and light modes, clean live wallpapers and matching system screens.**

[![License: MIT](https://img.shields.io/badge/license-MIT-9dae5c.svg)](#license)
[![Omarchy](https://img.shields.io/badge/Omarchy-Quattro-f2c84b.svg)](https://omarchy.org/)
[![Validate](https://github.com/sazardev/omarchy-mecha-green/actions/workflows/validate.yml/badge.svg)](https://github.com/sazardev/omarchy-mecha-green/actions/workflows/validate.yml)

| Mecha Green | Mecha Green Light |
|---|---|
| ![](themes/mecha-green/preview.png) | ![](themes/mecha-green-light/preview.png) |

## Features

- Two complete Omarchy themes with matching shell, terminal, editor and btop colours.
- Seven flat wallpapers and six clean live loops per theme.
- SDDM login and Plymouth boot screens using the same topographic identity.
- Mecha HUD and Mecha NET widgets for latency, CPU, RAM and battery status.
- Optional Halo wallpaper fetcher and live-wallpaper tools.

## Install

### Theme only

```sh
omarchy theme install https://github.com/sazardev/omarchy-mecha-green-theme
omarchy theme install https://github.com/sazardev/omarchy-mecha-green-light-theme
```

Apply a theme:

```sh
omarchy theme set "Mecha Green"
omarchy theme set "Mecha Green Light"
```

### Full setup

Installs both themes, the HUD, NET widget and CLI tools:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/sazardev/omarchy-mecha-green/main/install.sh)"
```

### Login and boot screens

Optional SDDM and Plymouth installation, with backup and initramfs rebuild:

```sh
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/sazardev/omarchy-mecha-green/main/system/install-login.sh)"
```

## Wallpapers

Each theme includes:

- `0-topographic` — the default brand wallpaper.
- `100-drift`, `101-fold`, `102-field`, `103-terrain`, `104-panorama` and `105-undulate`.
- Matching 8-second H.264 loops with animated lines and fixed Geist typography.

All stills are 2560×1440. Loops are 2560×1440, 24 fps and silent.

- Sources and renders: [`proposals/backgrounds/`](proposals/backgrounds/)
- Live gallery: [`proposals/backgrounds/live.html`](proposals/backgrounds/live.html)
- Full wallpaper guide: [`docs/WALLPAPERS.md`](docs/WALLPAPERS.md)

## System screens

| SDDM login | Plymouth boot |
|---|---|
| ![](screenshots/login-preview.webp) | ![](screenshots/plymouth-preview.webp) |

The lock screen follows the active wallpaper and uses the matching shell tokens.

## HUD and CLI

- [`Mecha HUD`](plugins/sazardev.mecha-hud/README.md) — `NET`, `THRT`, `AMMO` and optional `PWR`.
- [`Mecha NET`](plugins/sazardev.ping/README.md) — compact latency widget.
- `mecha-status`, `mecha-themetize`, `mecha-livewall` and `mecha-fetch-halo`.

See [`docs/INSTALL.md`](docs/INSTALL.md), [`docs/CUSTOMIZE.md`](docs/CUSTOMIZE.md) and [`docs/LIVE_WALLPAPERS.md`](docs/LIVE_WALLPAPERS.md) for details.

## License

MIT for the theme, scripts and original artwork. See [`LICENSE`](LICENSE).

Optional Halo artwork is not bundled and remains personal-use only. Halo, Master Chief, MCHOSE and Omarchy are trademarks of their respective owners.
