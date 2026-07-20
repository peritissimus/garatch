#!/usr/bin/env python3
"""Build a compact AngelCode BMFont atlas from a TTF for Connect IQ."""

import argparse
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ttf", required=True)
    parser.add_argument("--size", required=True, type=int)
    parser.add_argument("--chars", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--name", required=True)
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    font = ImageFont.truetype(args.ttf, args.size)
    ascent, descent = font.getmetrics()
    line_height = ascent + descent
    chars = list(dict.fromkeys(args.chars))
    padding = 2

    glyphs = []
    area = 0
    for char in chars:
        bbox = font.getbbox(char, anchor="ls")
        width = max(1, bbox[2] - bbox[0])
        height = max(1, bbox[3] - bbox[1])
        advance = round(font.getlength(char))
        glyphs.append((char, bbox, width, height, advance))
        area += (width + padding * 2) * (height + padding * 2)

    atlas_width = 1
    target = max(64, math.ceil(math.sqrt(area) * 1.35))
    while atlas_width < target:
        atlas_width *= 2

    placements = []
    x = padding
    y = padding
    row_height = 0
    for glyph in glyphs:
        char, bbox, width, height, advance = glyph
        cell_w = width + padding * 2
        cell_h = height + padding * 2
        if x + cell_w > atlas_width:
            x = padding
            y += row_height
            row_height = 0
        placements.append((glyph, x + padding, y + padding))
        x += cell_w
        row_height = max(row_height, cell_h)

    used_height = y + row_height + padding
    atlas_height = 1
    while atlas_height < used_height:
        atlas_height *= 2

    atlas = Image.new("L", (atlas_width, atlas_height), 0)
    draw = ImageDraw.Draw(atlas)
    lines = []
    for glyph, gx, gy in placements:
        char, bbox, width, height, advance = glyph
        # bbox is relative to the baseline; draw glyph into its tight cell.
        draw.text(
            (gx - bbox[0], gy - bbox[1]),
            char,
            font=font,
            fill=255,
            anchor="ls",
        )
        y_offset = ascent + bbox[1]
        lines.append(
            f"char id={ord(char)} x={gx} y={gy} width={width} height={height} "
            f"xoffset={bbox[0]} yoffset={y_offset} xadvance={advance} page=0 chnl=15"
        )

    png_name = args.name + ".png"
    atlas.save(out_dir / png_name, optimize=True)
    descriptor = [
        f'info face="{Path(args.ttf).stem}" size={args.size} bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=0,0',
        f"common lineHeight={line_height} base={ascent} scaleW={atlas_width} scaleH={atlas_height} pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0",
        f'page id=0 file="{png_name}"',
        f"chars count={len(lines)}",
        *lines,
    ]
    (out_dir / (args.name + ".fnt")).write_text("\n".join(descriptor) + "\n")


if __name__ == "__main__":
    main()
