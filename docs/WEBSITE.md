# Theme website

The static site lives in `site/` and deploys to Cloudflare Pages.

## URLs

| Purpose | URL |
|---|---|
| Production project | https://mecha-green.pages.dev |
| Custom domain | https://mecha.sazardev.stream |
| Cloudflare project | `mecha-green` |
| Account ID | `92b877a97b5acbd48f6d7dcf60129130` |

The custom domain is attached to the Pages project. It activates after the
`mecha` CNAME points at `mecha-green.pages.dev` with Cloudflare proxying enabled.

## Rebuild assets

```sh
python3 scripts/build-site-assets.py
```

This script regenerates:

- desktop 4K WebP downloads from the theme backgrounds;
- mobile 1440×3120 and tablet 2732×2048 lossless WebP cuts from the SVGs;
- ZIP packs for all three device classes;
- 1280×720 gallery images, 2400×1350 hero images and video posters;
- 1920×1080, 60 fps web preview loops;
- the vendored Geist webfonts used by the site.

Requirements: `rsvg-convert`, ImageMagick (`magick`) and `ffmpeg`. NVENC is used
automatically when an NVIDIA GPU is available; otherwise the script falls back
to x264.

## Deploy

The project uses direct uploads. A git push does not deploy the site.

```sh
npx wrangler pages deploy site \
  --project-name mecha-green \
  --branch main \
  --commit-dirty=true
```

If the Wrangler session expires:

```sh
npx wrangler login --device
```

## DNS

The current Wrangler OAuth token has Pages access but not DNS record editing.
Create this record once in the Cloudflare dashboard:

| Type | Name | Target | Proxy | TTL |
|---|---|---|---|---|
| CNAME | `mecha` | `mecha-green.pages.dev` | Proxied | Auto |

Do not create a second record for the same hostname. The pending custom domain
in Pages will validate automatically once the CNAME resolves.

## Site files

| Path | Purpose |
|---|---|
| `site/index.html` | One-page theme showcase and downloads |
| `site/styles.css` | Responsive dark/light design system |
| `site/main.js` | Theme switch, live loop selector, copy buttons |
| `site/_headers` | Security headers and cache policy |
| `site/404.html` | Real static 404 |
| `site/assets/downloads/` | Desktop, mobile and tablet wallpaper packs |
| `site/assets/video/` | 1080p web preview loops |
| `site/og-image.png` | Social preview card |

## Verification

```sh
curl -I https://mecha-green.pages.dev/
curl -I https://mecha-green.pages.dev/assets/video/drift-dark.mp4
curl -I https://mecha-green.pages.dev/no-such-page
```
