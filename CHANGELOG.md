# Changelog

## 1.7.2 — 2026-11-24

- Removed the optional Halo wallpaper filename and credit tables from the main
  README. Full credits remain available in `docs/WALLPAPERS.md`.

## 1.7.1 — 2026-11-24

- Removed legacy HUD, terminal, btop and lock-screen screenshots from the README.
- Deleted the old artwork captures so the project card only shows the new
  topographic wallpapers, SDDM login and Plymouth boot previews.

## 1.7.0 — 2026-11-23

- Added six new flat topographic designs: Drift, Fold, Field, Terrain, Panorama
  and Undulate, each in dark and light modes.
- Added twelve clean live wallpapers with animated contour lines and fixed Geist
  wordmarks. The loops are 2560×1440, 24 fps, 8 seconds, silent and effect-free.
- Bundled the new stills and loops in both themes under the collision-free
  `100-` series while keeping `0-topographic` as the default.
- Extended the topographic brand to SDDM login and Plymouth boot, removing the
  old radial HUD, glow, vignette, grid and decorative microtext.
- Added reproducible render scripts, refreshed previews and updated CI checks.
- Updated the registry-ready dark and light theme repositories.

## 1.6.1 — 2026-11-23

- Extended the flat topographic brand to SDDM login and Plymouth boot.
- Removed the old radial HUD, glow, vignette, grid and decorative microtext from
  both system screens.
- Added `scripts/render-system-assets.sh` and refreshed login/boot previews.
- Switched SDDM and Plymouth typography to Geist and updated CI checks.

## 1.6.0 — 2026-11-23

- Replaced the bundled wallpaper collection with one flat topographic wave per
  theme, using Geist typography and the exact dark/light background tokens.
- Made `0-topographic.webp` / `0-topographic-light.webp` the default brand
  wallpapers and removed the old stills and bundled live loops.
- Added `scripts/render-wallpapers.sh` to reproducibly render the wallpapers and
  theme previews at the canonical quality.
- Updated the installer to remove legacy theme-owned backgrounds while
  preserving personal wallpapers, and refreshed CI validation.
- Updated the registry-ready dark and light theme repositories.

## 1.5.0 — 2026-11-17

- Added two original MIT live wallpapers to each theme: a 12 s helmet command
  feed and a 12 s radar sweep. They are 2560×1440 H.264, silent, loop
  seamlessly and play natively through OWE.
- Added `mecha-livewall`: turn any image into a filtered live wallpaper with
  `command`, `rain`, `dust`, `pulse`, `storm` and `radar` styles.
- Added `mecha-live-set` / `make-live-set.sh`, which builds 7 dark and 5 light
  Halo live loops from the fetched stills, and `mecha-live-next`, which cycles
  videos only.
- Redesigned the Mecha HUD panel as a military command screen: integrity bars,
  objectives list, animated radar, scanline/grid backdrop, mission clock and
  a NEXT LIVE button.
- Added `--halo-live` to the installer, installed the live scripts and assets,
  and documented live wallpapers in README and docs.
- Updated the registry-ready theme repositories with the two MIT live loops.

## 1.4.1 — 2026-11-17

- Published registry-ready theme repositories for `omarchy theme install`:
  `mecha-green` and `mecha-green-light`, with `colors.toml`, `backgrounds/`
  and `preview.png` at the root.
- Submitted both themes to the Omarchy theme registry and the official extra
  themes gallery.
- Documented the standard Omarchy install path alongside the full installer.
- Fixed `keyboard.rgb` to the six-hex-digit format Omarchy expects, so the
  keyboard colour is applied.
- Removed ignored `selection_background` / `selection_foreground` palette keys.

## 1.4.0 — 2026-11-16

- Added four curated Halo sets, 21 dark and 21 light wallpapers: Spartans,
  UNSC, Covenant and Forerunner. All use the `mecha-themetize` palette filter
  and have publisher watermarks cropped out.
- Added `--set spartans,unsc` and `--list-sets` to the optional fetcher, with
  dark 22–42 / light 21–41 numbering.
- Local installs now carry 42 dark and 38 light backgrounds when the optional
  set is fetched.

## 1.3.0 — 2026-11-16

- Rebuilt the keyboard wallpaper as a product-style render with beveled
  keycaps, side faces, shadows, a case light bar, full legends and correct
  WASD/ESC/ENTER/arrow highlights.
- Added `mecha-themetize`: a CLI that maps any image onto the olive/amber
  palette, with dark/light modes, strength blending, 16:9 fit, optional grain
  and vignette, and `--install` auto-numbering.
- Added six dark and five light Halo/military backgrounds: dawn ring,
  Forerunner gate, Warthog canyon, tank dust, sunset helicopters, night jet and
  snow helicopter.
- Updated the optional fetcher to process the new set through the filter.

## 1.2.1 — 2026-11-16

- Normalized the SDDM and Plymouth PNG assets to 8-bit for maximum boot-time
  compatibility with the Plymouth image loader.
- Rebuilt the initramfs with the 8-bit assets.

## 1.2.0 — 2026-11-16

- Added a custom **Plymouth boot splash**: dark olive background, amber
  Omarchy mark, amber/olive progress bar and encryption prompt.
- Added a custom **SDDM login theme**: HUD background, amber Omarchy mark,
  amber password field, multiuser selector and error state.
- Verified the **lock screen** in both dark and light modes; the current
  wallpaper is blurred and the `[lock]` tokens from `shell.toml` theme the
  password field.
- Added `system/install-login.sh` and `system/uninstall-login.sh` with backups
  and initramfs rebuild.
- Added real login, boot and lock-screen previews.

## 1.1.1 — 2026-11-16

- Added real 1920×1080 desktop screenshots: dark hero, light switch blueprint,
  Mecha HUD panel, Mecha status CLI, btop dark/light and the light Warthog
  desktop.
- Mecha HUD shows the detected gateway as `LOCAL` in the ping-target strip
  instead of exposing the private IP in screenshots.
- README now opens with real desktop captures and a dedicated screenshot
  gallery.

## 1.1.0 — 2026-11-16

- Added five new original wallpaper pairs: Hall Effect switch blueprint, 75%
  PCB / switch matrix, tactical radar, MJOLNIR helmet schematic and field
  supply crate.
- Replaced the blue-heavy Halo scenes with a warm-curated set: warthog,
  desert and jungle replace the portal, dawn ring and blue field.
- Warm-graded the Master Chief field hero with a blue-channel mask, so the
  cyan beams and sky become olive / amber / cream.
- Updated the Halo fetcher, credits, gallery and docs.
- Added the new LUTs and SVG sources (all MIT).

## 1.0.1 — 2026-11-16

- Installer can set the bar background to `opaque` (default), `glassy` or
  `none`, or leave it alone with `--no-bar`.
- Added the bundled-wallpaper gallery to the README.
- Clarified `omarchy bar set` string/boolean examples.
- Hardened the installer and CLI host handling.

## 1.0.0 — 2026-11-16

- Added the **Mecha Green** dark theme and **Mecha Green Light** theme.
- Added custom `shell.toml` surfaces: olive/sand appbar, amber/bronze
  indicators, gradient borders, themed menus, launcher, notifications, lock and
  polkit prompts.
- Added amber/bronze Hyprland border gradients and custom Alacritty configs.
- Added original helmet, topographic and keyboard wallpapers in both modes.
- Added the **Mecha HUD** Quickshell plugin: NET, THRT, AMMO, optional PWR,
  telemetry panel, latency graph and ping-target switcher.
- Added the **Mecha NET** standalone bar widget.
- Added `mecha-status` CLI (`--json`, `--watch`) and `ping-status` command
  module.
- Added the optional Halo wallpaper fetcher with grading and credits.
- Added the one-command installer, uninstaller, docs and CI validation.
