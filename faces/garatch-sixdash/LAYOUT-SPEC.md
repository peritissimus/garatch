# SixDash pixel layout — Venu Sq 2

Coordinates are logical device pixels on a **320 × 360** canvas. Rectangles use
`x, y, width, height`. “Visible” excludes transparent padding in each PNG.

## Header

| Element | Draw geometry | PNG canvas | Visible pixels |
|---|---:|---:|---:|
| Bolt | `(29,44)` | `14×18` | `12×18`, offset `(+1,+0)` |
| Battery text | `(48,39)` | glyph cells `32×28` | Rajdhani Medium, source `27 px` |
| Temperature | right edge `x=262`; origin varies with value | glyph cells `32×28` | source `27 px` |
| Degree circle | center `(degreeX,45)`, radius `2` | — | stroke `2 px` |
| Bluetooth | `(276,43)` | `18×24` | `18×24`, offset `(+0,+0)` |
| Header rule | `(31,69,258,3)` | — | filled rectangle |

## Metric rows

| Row | Icon draw rectangle | Text origin | Segment origin |
|---|---|---|---|
| Steps | `(30,87,32,24)`; visible `29×21 +(+1,+2)` | `(75,75)` | `(75,101)` |
| Active minutes | `(30,110,34,30)`; visible `33×26 +(+1,+2)` | `(75,114)` | `(75,140)` |
| Distance | `(32,153,24,30)`; visible `20×29 +(+2,+0)` | `(75,153)` | `(75,179)` |

Each strip uses five `39×9` PNGs at x=`75,118,161,204,247`, separated by
`4 px`. Exact bitmap union: `(75,y,211,9)`. The function's `width=210`
argument is not the bitmap union: integer division produces a calculated 38 px
cell, while the resources are actually 39 px wide.

## Radials

- Centers: `(48,220)`, `(138,220)`, `(228,220)`.
- Radius `15 px`; stroke `6 px`.
- Foreground progress starts at `90°` (12 o'clock) and sweeps clockwise by
  `360 × pct`; the clockwise end angle is `90° − sweep`, normalized to 0–359°.
- Separators: `(111,204)→(111,244)` and `(201,204)→(201,244)`, `1 px`.
- Stress: draw `(75,197)`, canvas `20×21`, visible `17×18 +(+1,+1)`.
- Body Battery: draw `(168,198)`, canvas `15×20`, visible `11×20 +(+2,+0)`.
- Heart: draw `(254,197)`, canvas `21×20`, visible `20×19 +(+1,+0)`.
- Value origins: `(74,214)`, `(164,214)`, `(254,214)`.

## Clock and date

- Digit bitmap canvas: `64×68`.
- Digit canvases have transparent backgrounds; only visible numeral pixels are
  composited, preventing the clock cells at `y=237` from clipping radial values.
- Font source: **Rajdhani Medium, 72 px**, resized by the asset
  script to a 56 px-high render inside each 64×68 cell.
- Digit origins: `(24,237)`, `(61,237)`, `(121,237)`, `(158,237)`,
  `(218,237)`, `(255,237)`.
- Advance `37 px`.
- Colon centers: `(111,266)`, `(111,284)`, `(208,266)`, `(208,284)`.
- Colon radius `3 px`; vertical separation `18 px`.
- Complete cell union: `(24,237,295,68)`; final included x-coordinate `318`.
- Date origin `(30,296)`; glyph canvas `32×32`; source size `33 px`.

## Small bitmap font

- **Rajdhani Medium**, source size `27 px`.
- Every glyph canvas is `32×28`; normal visible glyph height is `18 px`.
- Glyphs have 4 px of left-side atlas guard space; draw calls compensate by
  `-4 px`, preserving the original optical alignment without edge clipping.
- Advances: digits `11`, dot `5`, percent `18`, dash `8`, `F` `10`, `C` `11`.
- Glyph rectangles overlap intentionally; advances—not 32 px cell widths—set
  the text layout.

## Colors

`INK #F1F3E8`, `WARM #C9CBAE`, `CYAN #49BBC2`, `MINT #56D39B`,
`DIM #36383A`, `TRACK #202425`, background `#000000`.
