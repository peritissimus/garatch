# Typography and Layout on Venu SQ 2

## Device facts

- `venusq2` and `venusq2m` use a 320×360 rectangular, 65K-color AMOLED display.
- A watch face has a 131,072-byte memory limit.
- Treat 320×360 as the design canvas. Do not resize a square composition into it.
- Authoritative sources: [Garmin Venu SQ 2 Device Reference](https://developer.garmin.com/connect-iq/device-reference/venusq2/) and the installed `Devices/venusq2/compiler.json`.

## Typography choices

Garmin provides text fonts and number-only fonts. System fonts are readable but vary by device and rarely match a polished external mockup. Use them for portability; use a custom bitmap font when typography defines the face.

Custom font workflow:

1. Use a redistributable TTF/OTF and include its license.
2. Generate a BMFont `.fnt` plus grayscale PNG atlas. This skill includes `scripts/make_bmfont.py`.
3. Create separate sizes/weights by role: hero number, supporting value, label/header.
4. Filter each atlas to only characters that role can display. Large number fonts should normally include only `0123456789,:.-%` as needed.
5. Declare fonts in `resources/fonts/fonts.xml` with `<font id="..." filename="..." antialias="true" filter="..." />`.
6. Load once in `onLayout` with `WatchUi.loadResource(Rez.Fonts.Name)` and cache the result.
7. Use `dc.getTextDimensions`, `dc.getTextWidthInPixels`, and font height/ascent/descent to validate bounds. Never assume browser CSS line-height or image-generator typography matches Garmin.

## Tested Barlow Condensed role system

`garatch-telemetry` validated this compact set in the Venu SQ 2 simulator:

| Role | Font | Size | Typical filter |
|---|---|---:|---|
| Time | Barlow Condensed Regular | 104 | `0123456789:` |
| Metric value | Barlow Condensed Medium | 36 | `0123456789,-` |
| Label/unit/header | Barlow Condensed Medium | 18 | `ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:% -` |

Keep the Barlow OFL license with the face. Separate filtered atlases keep resources small and prevent a label alphabet from inflating the hero-number atlas. Ensure every runtime character is present in both the generated atlas and the XML `filter`; a missing comma, percent, colon, or dash becomes a blank glyph.

Official references: [Resources and custom fonts](https://developer.garmin.com/connect-iq/core-topics/resources/), [Graphics and text measurement](https://developer.garmin.com/connect-iq/core-topics/graphics/), [Dc API](https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html), and [Garmin visual-design guidance](https://developer.garmin.com/connect-iq/user-experience-guidelines/incorporating-the-visual-design-and-product-personalities/).

## Layout method

1. Make a 320×360 mockup first and verify its file metadata.
2. Define a small number of horizontal bands and safe margins. Do not position every string independently without a shared grid.
3. Cache all anchors and font resources in `onLayout`.
4. Use `TEXT_JUSTIFY_VCENTER` when positioning by optical centers; use measured ascent/descent when aligning baselines.
5. Center two-column metric values within fixed column centers (`w/4`, `3*w/4`) instead of left-aligning both columns.
6. Test realistic and worst-case strings: `88,888` steps, `199 BPM`, `9999 KCAL`, 12-hour and 24-hour time, and the widest localized date.
7. Build and inspect the actual Venu SQ 2 simulator. Inject activity data through **Simulation → Activity Monitoring → Set Activity Monitor Info**. A zero-data render is not sufficient validation.
8. Test active and sleep/always-on modes. Keep always-on typography thin, dim, sparse, and shifted by up to four pixels.

### Metric-grid alignment

- For a three-column 320-pixel layout with 20-pixel margins, use centers near `53`, `160`, and `267`; separators near `107` and `213`. Treat these as a tested starting grid, then adjust optically in the simulator.
- Center labels on the column center. For plain numeric values, center the value directly.
- For a value plus a smaller unit, center the pair from measured widths instead of centering the value and appending the unit:

```monkeyc
var valueW = dc.getTextWidthInPixels(value, valueFont);
var unitW = dc.getTextWidthInPixels(unit, labelFont);
var startX = centerX - ((valueW + 3 + unitW) / 2);
dc.drawText(startX, y, valueFont, value,
    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
dc.drawText(startX + valueW + 3, y + 5, labelFont, unit,
    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
```

Measuring a changing string here is the justified `onUpdate` exception; cache the fonts and fixed column geometry in `onLayout`. Keep `BPM`, `%`, and `KCAL` visually subordinate to the number.

## BMFont generator

Run with the bundled workspace Python (Pillow required):

```sh
python scripts/make_bmfont.py \
  --ttf path/to/Font.ttf \
  --size 96 \
  --chars '0123456789,' \
  --out faces/<face>/resources/fonts \
  --name hero
```

The output uses the AngelCode text descriptor format expected by Garmin. Build immediately after generation, then inspect the simulator; glyph-channel or baseline errors are visible only after resource compilation.

If the default Python lacks Pillow, call `codex_app__load_workspace_dependencies` and run the script with its bundled Python path. The generator emits grayscale atlases with `chnl=15` and baseline offsets compatible with Garmin's resource compiler; do not change those fields without rebuilding and checking actual glyphs in the simulator.
