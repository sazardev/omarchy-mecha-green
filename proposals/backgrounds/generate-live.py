#!/usr/bin/env python3
"""Generate clean looping topographic live wallpapers from the proposal SVGs."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PROJECT_ROOT = ROOT.parents[1]
SVG_DIR = ROOT / "svg"
OUT_DIR = ROOT / "live"
SOURCE_WIDTH = 2560
SOURCE_HEIGHT = 1440
WIDTH = 3840
HEIGHT = 2160
SCALE = WIDTH / SOURCE_WIDTH
FPS = 24
DURATION = 8
SVG_NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", SVG_NS)
THEME_NUMBERS = {
    "01": "100",
    "02": "101",
    "03": "102",
    "04": "103",
    "05": "104",
    "06": "105",
}


def qname(tag: str) -> str:
    return f"{{{SVG_NS}}}{tag}"


def render_layers(source: Path, work: Path) -> tuple[Path, Path, str]:
    tree = ET.parse(source)
    root = tree.getroot()
    background = "#0e1009"
    for child in root:
        if (
            child.tag == qname("rect")
            and child.attrib.get("width") == str(SOURCE_WIDTH)
            and child.attrib.get("height") == str(SOURCE_HEIGHT)
        ):
            background = child.attrib.get("fill", background)
            break

    # Keep the original design coordinates while rendering every layer at 4K.
    line_root = ET.Element(
        qname("svg"),
        {
            "width": str(WIDTH),
            "height": str(HEIGHT),
            "viewBox": f"0 0 {SOURCE_WIDTH} {SOURCE_HEIGHT}",
        },
    )
    overlay_root = ET.Element(
        qname("svg"),
        {
            "width": str(WIDTH),
            "height": str(HEIGHT),
            "viewBox": f"0 0 {SOURCE_WIDTH} {SOURCE_HEIGHT}",
        },
    )

    line_root.append(
        ET.Element(
            qname("rect"),
            {"width": str(WIDTH), "height": str(HEIGHT), "fill": background},
        )
    )
    overlay_root.append(
        ET.Element(
            qname("rect"),
            {
                "width": str(WIDTH),
                "height": str(HEIGHT),
                "fill": "#000000",
                "fill-opacity": "0",
            },
        )
    )

    for child in root:
        if child.tag in (qname("defs"), qname("g")):
            line_root.append(child)
        elif child.tag == qname("text"):
            overlay_root.append(child)
        elif child.tag == qname("rect"):
            is_background = (
                child.attrib.get("width") == str(SOURCE_WIDTH)
                and child.attrib.get("height") == str(SOURCE_HEIGHT)
                and child.attrib.get("fill") == background
            )
            if not is_background:
                overlay_root.append(child)

    line_svg = work / "lines.svg"
    overlay_svg = work / "overlay.svg"
    line_png = work / "lines.png"
    overlay_png = work / "overlay.png"
    ET.ElementTree(line_root).write(line_svg, encoding="utf-8", xml_declaration=True)
    ET.ElementTree(overlay_root).write(
        overlay_svg, encoding="utf-8", xml_declaration=True
    )

    for svg, png in ((line_svg, line_png), (overlay_svg, overlay_png)):
        subprocess.run(
            [
                "rsvg-convert",
                "--width",
                str(WIDTH),
                "--height",
                str(HEIGHT),
                str(svg),
                "--output",
                str(png),
            ],
            check=True,
        )

    return line_png, overlay_png, background


def install(output: Path) -> None:
    source_number, name, mode = output.stem.split("-", 2)
    theme = "mecha-green-light" if mode == "light" else "mecha-green"
    suffix = "-light" if mode == "light" else ""
    target = (
        PROJECT_ROOT
        / "themes"
        / theme
        / "backgrounds"
        / f"{THEME_NUMBERS[source_number]}-{name}{suffix}.mp4"
    )
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(output, target)
    print(f"Installed {target.relative_to(PROJECT_ROOT)}")


def generate(source: Path, install_output: bool = False) -> Path:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUT_DIR / f"{source.stem}.mp4"
    with tempfile.TemporaryDirectory(prefix="mecha-live-") as tmp:
        line_png, overlay_png, background = render_layers(source, Path(tmp))
        color = background.replace("#", "0x")
        phase = f"2*PI*T/{DURATION}"
        wavelength_x = 640 * SCALE
        wavelength_y = 360 * SCALE
        displacement_x = 8 * SCALE
        displacement_y = 22 * SCALE
        # Composite in full-range RGB so the later BT.709 limited-range
        # conversion does not lift the dark background or shift its colours.
        displacement = (
            "[0:v]format=gbrp[line];"
            "[1:v]format=gbrap[overlay];"
            "[2:v]split=2[xbase][ybase];"
            "[xbase]format=gray,"
            f"geq=lum='128+{displacement_x:g}*sin(2*PI*X/{wavelength_x:g}+{phase})',"
            f"scale={WIDTH}:{HEIGHT}[xmap];"
            "[ybase]format=gray,"
            f"geq=lum='128+{displacement_y:g}*sin(2*PI*Y/{wavelength_y:g}+{phase})',"
            f"scale={WIDTH}:{HEIGHT}[ymap];"
            "[line][xmap][ymap]displace=edge=wrap[warp];"
            "[warp][overlay]overlay=0:0:format=gbrp:alpha=straight,"
            "scale=in_range=full:out_range=tv:out_color_matrix=bt709,"
            "format=yuv420p[out]"
        )
        command = [
            "ffmpeg",
            "-hide_banner",
            "-loglevel",
            "error",
            "-y",
            "-loop",
            "1",
            "-framerate",
            str(FPS),
            "-i",
            str(line_png),
            "-loop",
            "1",
            "-framerate",
            str(FPS),
            "-i",
            str(overlay_png),
            "-f",
            "lavfi",
            "-i",
            f"color=c={color}:s={WIDTH}x{HEIGHT}:r={FPS}:d={DURATION}",
            "-filter_complex",
            displacement,
            "-map",
            "[out]",
            "-t",
            str(DURATION),
            "-r",
            str(FPS),
            "-an",
            "-c:v",
            "libx264",
            "-preset",
            "slow",
            "-tune",
            "animation",
            "-crf",
            "15",
            "-profile:v",
            "high",
            "-level:v",
            "5.1",
            "-x264-params",
            "colorprim=bt709:transfer=bt709:colormatrix=bt709",
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
            "-movflags",
            "+faststart",
            str(output),
        ]
        subprocess.run(command, check=True)
    print(f"Generated {output.name}")
    if install_output:
        install(output)
    return output


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--only", help="Render only one SVG stem, for testing")
    parser.add_argument(
        "--install",
        action="store_true",
        help="Copy rendered loops into both theme background directories",
    )
    args = parser.parse_args()

    sources = sorted(SVG_DIR.glob("*.svg"))
    if args.only:
        sources = [source for source in sources if source.stem == args.only]
        if not sources:
            raise SystemExit(f"No SVG found for {args.only}")

    for source in sources:
        generate(source, args.install)


if __name__ == "__main__":
    main()
