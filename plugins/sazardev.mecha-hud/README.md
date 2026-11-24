# Mecha HUD

A clean, flat system monitor for the Omarchy bar: **NET** latency, **THRT** CPU
load, **AMMO** RAM pressure and optional **PWR** battery.

The panel follows the Mecha Green topographic design system: Geist typography,
olive/sand surfaces, simple status cards and a minimal radar. No franchise text,
scanlines, glow or HUD frames.

## Install

```sh
cp -r plugins/sazardev.mecha-hud ~/.config/omarchy/plugins/
omarchy-shell shell rescanPlugins
omarchy plugin enable sazardev.mecha-hud --section right --after omarchy.power
```

The full installer does this automatically unless you pass `--no-hud`.

## Interactions

| Action | Result |
|---|---|
| Left click | Open the system monitor |
| Middle click | Refresh all telemetry |
| Right click | Cycle Cloudflare → Google → gateway |
| Hover | Show a compact status tooltip |

The panel includes network, CPU, memory and power status, a 60-sample latency
graph, ping-target switcher, uptime, reset and **NEXT LIVE** wallpaper control.

## Settings

```sh
omarchy bar set sazardev.mecha-hud pingHost 8.8.8.8
omarchy bar set sazardev.mecha-hud pingIntervalSec 5
omarchy bar set sazardev.mecha-hud showCpu true
```

| Key | Type | Default |
|---|---|---|
| `pingHost` | string | `1.1.1.1` |
| `pingIntervalSec` | integer (2–60) | `5` |
| `showCpu` | boolean | `true` |
| `showAmmo` | boolean | `true` |
| `showPower` | boolean | `true` |

## Notes

- Ping hosts are sanitized and passed as a separate argument.
- `NEXT LIVE` uses `mecha-live-next`; if unavailable, it cycles all backgrounds.
- Requires the Omarchy shell (Quickshell).
