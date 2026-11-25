#!/usr/bin/env python3
"""Build the Mecha Green website assets and mobile/tablet wallpaper cuts."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / "site"
ASSETS = SITE / "assets"
DOWNLOADS = ASSETS / "downloads"
IMAGES = ASSETS / "images"
VIDEOS = ASSETS / "video"
FONTS = ASSETS / "fonts"
SOURCE_WIDTH = 2560
SOURCE_HEIGHT = 1440
SVG_NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", SVG_NS)

TARGETS = {
    "mobile": (1440, 3120),
    "tablet": (2732, 2048),
}

STILLS = [
    ("topographic", "dark", ROOT / "assets/svg/topo-dark.svg"),
    ("topographic", "light", ROOT / "assets/svg/topo-light.svg"),
]
for number, slug in (
    ("01", "drift"),
    ("02", "fold"),
    ("03", "field"),
    ("04", "terrain"),
    ("05", "panorama"),
    ("06", "undulate"),
):
    for mode in ("dark", "light"):
        STILLS.append(
            (
                slug,
                mode,
                ROOT / f"proposals/backgrounds/svg/{number}-{slug}-{mode}.svg",
            )
        )

LOOPS = [
    ("drift", "100-drift"),
    ("fold", "101-fold"),
    ("field", "102-field"),
    ("terrain", "103-terrain"),
    ("panorama", "104-panorama"),
    ("undulate", "105-undulate"),
]
STILL_NUMBERS = {
    "topographic": "0",
    "drift": "100",
    "fold": "101",
    "field": "102",
    "terrain": "103",
    "panorama": "104",
    "undulate": "105",
}
MODES = ("dark", "light")


def qname(tag: str) -> str:
    return f"{{{SVG_NS}}}{tag}"


def require(commands: tuple[str, ...]) -> None:
    for command in commands:
        if shutil.which(command) is None:
            raise SystemExit(f"Missing required command: {command}")


def gpu_encoder_available() -> bool:
    if not Path("/dev/nvidia0").exists():
        return False
    encoders = subprocess.run(
        ["ffmpeg", "-hide_banner", "-encoders"],
        text=True,
        capture_output=True,
        check=True,
    ).stdout
    return "h264_nvenc" in encoders


def encoder_options(requested: str) -> list[str]:
    encoder = requested
    if encoder == "auto":
        encoder = "nvenc" if gpu_encoder_available() else "x264"
    if encoder == "nvenc":
        return [
            "-c:v",
            "h264_nvenc",
            "-preset",
            "p7",
            "-tune",
            "hq",
            "-rc",
            "vbr",
            "-cq",
            "19",
            "-b:v",
            "0",
            "-maxrate",
            "15M",
            "-bufsize",
            "30M",
            "-multipass",
            "fullres",
            "-rc-lookahead",
            "32",
            "-spatial-aq",
            "1",
            "-temporal-aq",
            "1",
            "-aq-strength",
            "8",
            "-bf",
            "3",
            "-b_ref_mode",
            "middle",
            "-no-scenecut",
            "1",
        ]
    return [
        "-c:v",
        "libx264",
        "-preset",
        "slow",
        "-tune",
        "animation",
        "-crf",
        "18",
        "-x264-params",
        "colorprim=bt709:transfer=bt709:colormatrix=bt709",
    ]


def parse_source(path: Path) -> tuple[str, str, list[ET.Element], list[ET.Element]]:
    root = ET.parse(path).getroot()
    background = "#0e1009"
    text_fill = "#d8d9b4"
    defs: list[ET.Element] = []
    groups: list[ET.Element] = []
    for child in root:
        if child.tag == qname("rect"):
            if (
                child.attrib.get("width") == str(SOURCE_WIDTH)
                and child.attrib.get("height") == str(SOURCE_HEIGHT)
            ):
                background = child.attrib.get("fill", background)
        elif child.tag == qname("text"):
            text_fill = child.attrib.get("fill", text_fill)
        elif child.tag in (qname("defs"), qname("g")):
            (defs if child.tag == qname("defs") else groups).append(child)
    return background, text_fill, defs, groups


def render_device(
    source: Path, slug: str, mode: str, target_name: str, work: Path
) -> Path:
    width, height = TARGETS[target_name]
    background, text_fill, defs, groups = parse_source(source)
    scale = max(width / SOURCE_WIDTH, height / SOURCE_HEIGHT)
    offset_x = (width - SOURCE_WIDTH * scale) / 2
    offset_y = (height - SOURCE_HEIGHT * scale) / 2

    root = ET.Element(
        qname("svg"),
        {
            "width": str(width),
            "height": str(height),
            "viewBox": f"0 0 {width} {height}",
            "role": "img",
        },
    )
    ET.SubElement(
        root,
        qname("rect"),
        {"width": str(width), "height": str(height), "fill": background},
    )
    for element in defs:
        root.append(element)
    container = ET.SubElement(
        root,
        qname("g"),
        {
            "transform": (
                f"translate({offset_x:.3f} {offset_y:.3f}) scale({scale:.6f})"
            )
        },
    )
    for element in groups:
        container.append(element)

    unit = min(width, height)
    font_size = round(unit * 0.064)
    margin = round(unit * 0.054)
    baseline = height - margin
    plate_width = round(font_size * 6.8)
    plate_height = round(font_size * 1.55)
    plate_y = baseline - round(font_size * 1.15)
    ET.SubElement(
        root,
        qname("rect"),
        {
            "x": str(round(margin * 0.55)),
            "y": str(plate_y),
            "width": str(plate_width),
            "height": str(plate_height),
            "fill": background,
        },
    )
    ET.SubElement(
        root,
        qname("text"),
        {
            "x": str(margin),
            "y": str(baseline),
            "font-family": "Geist, sans-serif",
            "font-size": str(font_size),
            "font-weight": "500",
            "letter-spacing": str(round(-font_size * 0.045)),
            "fill": text_fill,
        },
    ).text = "Mecha Green"

    svg_path = work / f"{source.stem}-{target_name}.svg"
    png_path = work / f"{source.stem}-{target_name}.png"
    ET.ElementTree(root).write(svg_path, encoding="utf-8", xml_declaration=True)
    subprocess.run(
        [
            "rsvg-convert",
            "--width",
            str(width),
            "--height",
            str(height),
            str(svg_path),
            "--output",
            str(png_path),
        ],
        check=True,
    )
    output = DOWNLOADS / target_name / f"mecha-green-{slug}-{mode}-{target_name}.webp"
    output.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "magick",
            str(png_path),
            "-strip",
            "-define",
            "webp:lossless=true",
            "-quality",
            "100",
            str(output),
        ],
        check=True,
    )
    return output


def theme_still(slug: str, mode: str) -> Path:
    theme = "mecha-green-light" if mode == "light" else "mecha-green"
    suffix = "-light" if mode == "light" else ""
    return (
        ROOT
        / "themes"
        / theme
        / "backgrounds"
        / f"{STILL_NUMBERS[slug]}-{slug}{suffix}.webp"
    )


def copy_desktop(still: tuple[str, str, Path]) -> Path:
    slug, mode, _ = still
    output = DOWNLOADS / "desktop" / f"mecha-green-{slug}-{mode}.webp"
    output.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(theme_still(slug, mode), output)
    return output


def make_gallery_image(still: tuple[str, str, Path]) -> Path:
    slug, mode, source = still
    output = IMAGES / "gallery" / f"{slug}-{mode}.webp"
    output.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "magick",
            source,
            "-resize",
            "1280x720^",
            "-gravity",
            "center",
            "-extent",
            "1280x720",
            "-strip",
            "-quality",
            "90",
            str(output),
        ],
        check=True,
    )
    return output


def make_hero() -> None:
    hero = ROOT / "themes/mecha-green/backgrounds/0-topographic.webp"
    hero_light = ROOT / "themes/mecha-green-light/backgrounds/0-topographic-light.webp"
    for source, name in ((hero, "hero-dark"), (hero_light, "hero-light")):
        subprocess.run(
            [
                "magick",
                source,
                "-resize",
                "2400x1350^",
                "-gravity",
                "center",
                "-extent",
                "2400x1350",
                "-strip",
                "-quality",
                "90",
                str(IMAGES / f"{name}.webp"),
            ],
            check=True,
        )


def make_web_video(slug: str, mode: str, requested_encoder: str = "auto") -> Path:
    if mode == "dark":
        source = ROOT / f"themes/mecha-green/backgrounds/{dict(LOOPS)[slug]}.mp4"
    else:
        source = (
            ROOT
            / f"themes/mecha-green-light/backgrounds/{dict(LOOPS)[slug]}-light.mp4"
        )
    output = VIDEOS / f"{slug}-{mode}.mp4"
    output.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-i",
            str(source),
            "-vf",
            "scale=1920:1080:flags=lanczos,format=yuv420p",
            "-an",
            "-r",
            "60",
            *encoder_options(requested_encoder),
            "-profile:v",
            "high",
            "-level:v",
            "4.2",
            "-pix_fmt",
            "yuv420p",
            "-color_range",
            "tv",
            "-colorspace",
            "bt709",
            "-color_primaries",
            "bt709",
            "-color_trc",
            "bt709",
            "-bsf:v",
            "h264_metadata=colour_primaries=1:transfer_characteristics=1:matrix_coefficients=1",
            "-movflags",
            "+faststart",
            str(output),
        ],
        check=True,
    )
    return output


def zip_dir(folder: Path, output: Path, title: str) -> None:
    readme = (
        f"{title}\n\n"
        "Mecha Green for Omarchy — MIT licensed.\n"
        "Artwork: https://github.com/sazardev/omarchy-mecha-green\n"
        "All wallpapers are rendered from the original SVG sources.\n"
    )
    files = sorted(path for path in folder.iterdir() if path.is_file())
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_STORED) as archive:
        for path in files:
            archive.write(path, f"{title}/{path.name}")
        archive.writestr(f"{title}/README.txt", readme)


def copy_fonts() -> None:
    font_root = ROOT / "assets/fonts"
    candidates = {
        "geist-variable.woff2": font_root / "Geist[wght].woff2",
        "geist-mono-variable.woff2": font_root / "GeistMono[wght].woff2",
    }
    FONTS.mkdir(parents=True, exist_ok=True)
    for name, source in candidates.items():
        if not source.exists():
            raise SystemExit(f"Missing vendored Geist webfont: {source}")
        shutil.copy2(source, FONTS / name)
    shutil.copy2(font_root / "OFL.txt", FONTS / "OFL.txt")


def write_manifest(
    desktop: list[Path], mobile: list[Path], tablet: list[Path]
) -> None:
    manifest = {
        "name": "Mecha Green",
        "version": "1.8.1",
        "desktop": [path.name for path in desktop],
        "mobile": {"size": TARGETS["mobile"], "files": [path.name for path in mobile]},
        "tablet": {"size": TARGETS["tablet"], "files": [path.name for path in tablet]},
    }
    (DOWNLOADS / "manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--skip-video", action="store_true")
    parser.add_argument("--skip-devices", action="store_true")
    parser.add_argument(
        "--encoder",
        choices=("auto", "nvenc", "x264"),
        default="auto",
        help="Hardware encoder for web loops; auto prefers NVENC",
    )
    args = parser.parse_args()

    require(("rsvg-convert", "magick", "ffmpeg"))
    for folder in (DOWNLOADS, IMAGES, VIDEOS, FONTS):
        folder.mkdir(parents=True, exist_ok=True)

    copy_fonts()
    make_hero()

    desktop: list[Path] = []
    mobile: list[Path] = []
    tablet: list[Path] = []
    with tempfile.TemporaryDirectory(prefix="mecha-site-") as tmp:
        work = Path(tmp)
        for still in STILLS:
            desktop.append(copy_desktop(still))
            make_gallery_image(still)
            if not args.skip_devices:
                mobile.append(render_device(still[2], still[0], still[1], "mobile", work))
                tablet.append(render_device(still[2], still[0], still[1], "tablet", work))

    if not args.skip_devices:
        shutil.copy2(
            DOWNLOADS / "mobile/mecha-green-topographic-dark-mobile.webp",
            IMAGES / "device-mobile-dark.webp",
        )
        shutil.copy2(
            DOWNLOADS / "mobile/mecha-green-topographic-light-mobile.webp",
            IMAGES / "device-mobile-light.webp",
        )
        shutil.copy2(
            DOWNLOADS / "tablet/mecha-green-topographic-dark-tablet.webp",
            IMAGES / "device-tablet-dark.webp",
        )
        shutil.copy2(
            DOWNLOADS / "tablet/mecha-green-topographic-light-tablet.webp",
            IMAGES / "device-tablet-light.webp",
        )
        zip_dir(
            DOWNLOADS / "mobile",
            DOWNLOADS / "mecha-green-mobile.zip",
            "Mecha Green Mobile",
        )
        zip_dir(
            DOWNLOADS / "tablet",
            DOWNLOADS / "mecha-green-tablet.zip",
            "Mecha Green Tablet",
        )
        write_manifest(desktop, mobile, tablet)

    zip_dir(
        DOWNLOADS / "desktop",
        DOWNLOADS / "mecha-green-desktop-4k.zip",
        "Mecha Green Desktop 4K",
    )

    if not args.skip_video:
        (IMAGES / "posters").mkdir(parents=True, exist_ok=True)
        for slug, _ in LOOPS:
            for mode in MODES:
                output = make_web_video(slug, mode, args.encoder)
                poster_mode = "light" if mode == "light" else "dark"
                subprocess.run(
                    [
                        "magick",
                        ROOT
                        / f"themes/mecha-green{'-light' if poster_mode == 'light' else ''}/backgrounds/{dict(LOOPS)[slug]}{'-light' if poster_mode == 'light' else ''}.webp",
                        "-resize",
                        "1280x720^",
                        "-gravity",
                        "center",
                        "-extent",
                        "1280x720",
                        "-strip",
                        "-quality",
                        "88",
                        str(IMAGES / "posters" / f"{slug}-{mode}.webp"),
                    ],
                    check=True,
                )
                print(f"Built {output.name}")

    print("Site assets ready.")


if __name__ == "__main__":
    main()
