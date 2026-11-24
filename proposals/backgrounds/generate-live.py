#!/usr/bin/env python3
"""Generate clean looping topographic live wallpapers from the proposal SVGs."""

from __future__ import annotations

import argparse
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SVG_DIR = ROOT / "svg"
OUT_DIR = ROOT / "live"
WIDTH = 2560
HEIGHT = 1440
FPS = 24
DURATION = 8
SVG_NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", SVG_NS)


def qname(tag: str) -> str:
    return f"{{{SVG_NS}}}{tag}"


def render_layers(source: Path, work: Path) -> tuple[Path, Path, str]:
    tree = ET.parse(source)
    root = tree.getroot()
    background = "#0e1009"
    for child in root:
        if child.tag == qname("rect") and child.attrib.get("width") == str(WIDTH):
            background = child.attrib.get("fill", background)
            break

    line_root = ET.Element(
        qname("svg"),
        {
            "width": str(WIDTH),
            "height": str(HEIGHT),
            "viewBox": f"0 0 {WIDTH} {HEIGHT}",
        },
    )
    overlay_root = ET.Element(
        qname("svg"),
        {
            "width": str(WIDTH),
            "height": str(HEIGHT),
            "viewBox": f"0 0 {WIDTH} {HEIGHT}",
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
                child.attrib.get("width") == str(WIDTH)
                and child.attrib.get("height") == str(HEIGHT)
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


def generate(source: Path) -> Path:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUT_DIR / f"{source.stem}.mp4"
    with tempfile.TemporaryDirectory(prefix="mecha-live-") as tmp:
        line_png, overlay_png, background = render_layers(source, Path(tmp))
        color = background.replace("#", "0x")
        phase = f"2*PI*T/{DURATION}"
        displacement = (
            "[0:v]format=gbrp[line];"
            "[2:v]split=2[xbase][ybase];"
            "[xbase]format=gray,"
            f"geq=lum='128+8*sin(2*PI*X/640+{phase})',"
            f"scale={WIDTH}:{HEIGHT}[xmap];"
            "[ybase]format=gray,"
            f"geq=lum='128+22*sin(2*PI*Y/360+{phase})',"
            f"scale={WIDTH}:{HEIGHT}[ymap];"
            "[line][xmap][ymap]displace=edge=wrap[warp];"
            "[warp][1:v]overlay=0:0[out]"
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
            "fast",
            "-crf",
            "18",
            "-pix_fmt",
            "yuv420p",
            "-movflags",
            "+faststart",
            str(output),
        ]
        subprocess.run(command, check=True)
    print(f"Generated {output.name}")
    return output


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--only", help="Render only one SVG stem, for testing")
    args = parser.parse_args()

    sources = sorted(SVG_DIR.glob("*.svg"))
    if args.only:
        sources = [source for source in sources if source.stem == args.only]
        if not sources:
            raise SystemExit(f"No SVG found for {args.only}")

    for source in sources:
        generate(source)


if __name__ == "__main__":
    main()
