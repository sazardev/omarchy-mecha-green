# Mecha Green Plymouth boot splash

A dark-olive Plymouth theme with the amber Omarchy mark and an amber progress
bar. It also handles the disk-encryption password prompt with an olive field
and amber bullets.

![Mecha Green boot preview](../../../screenshots/plymouth-preview.webp)

## Files

| File | Purpose |
|---|---|
| `mecha-green.plymouth` | Theme descriptor |
| `mecha-green.script` | Plymouth script (background, layout, progress) |
| `logo.png` | Amber Omarchy wordmark |
| `progress_box.png` / `progress_bar.png` | Amber-on-olive progress bar |
| `entry.png` / `lock.png` / `bullet.png` | Encryption password prompt |
| `preview.webp` | 1920×1080 design preview |

## Install

Run from the repository root:

```sh
sudo ./system/install-login.sh
```

The installer copies this directory to
`/usr/share/plymouth/themes/mecha-green`, sets it with
`plymouth-set-default-theme`, and rebuilds the initramfs. It applies on the
next boot.

Undo:

```sh
sudo ./system/uninstall-login.sh
```

## Notes

- The background colour is `#0e1009`; the progress bar and mark are `#f2c84b`
  with an olive `#3f4a22` frame.
- The theme uses the Omarchy Plymouth script layout, so it keeps the same
  progress timing, display hotplug handling and encryption prompt behaviour.
