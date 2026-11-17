# Mecha NET

A compact military `NET` latency readout for the Omarchy bar. It is the
lightweight alternative to the full Mecha HUD.

## Install

```sh
cp -r plugins/sazardev.ping ~/.config/omarchy/plugins/
omarchy-shell shell rescanPlugins
omarchy plugin enable sazardev.ping --section right --after omarchy.network
```

## Interactions

- Shows `NET 044` in amber below 40 ms, sage below 100 ms and rust otherwise.
- Hover for latency, average, packet loss and target.
- Left click opens a floating terminal with a four-packet ping test.
- Middle click refreshes the sample.

## Settings

```sh
omarchy bar set sazardev.ping pingHost 1.1.1.1
omarchy bar set sazardev.ping pingIntervalSec 5
```

| Key | Type | Default |
|---|---|---|
| `pingHost` | string | `1.1.1.1` |
| `pingIntervalSec` | integer (2–60) | `5` |

The host is sanitized and passed as a separate argument to `ping`; no shell
interpolation is used.
