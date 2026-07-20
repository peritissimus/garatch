# Garatch Telemetry — design system

The live Venu Sq 2 simulator is the rendering reference; raster preview exports are diagnostic snapshots only.

## Visual thesis

Garatch Telemetry is a compact instrument panel: information-dense, but organized by a strict frame and repeated visual grammar. The six marks visible in the simulator belong to the physical watch casing. They are used only as external alignment references and are never drawn by the watch face.

## Grid and spacing

- Measured simulator canvas: 320 × 360 px AMOLED.
- Safe content field: x=30…290; outer markers occupy the remaining edge space.
- The casing's top/bottom center marks verify the horizontal center; its four side marks verify the vertical bands without entering the drawable UI.
- Primary vertical bands: status (39–72), segmented metrics (75–190), radial metrics (198–244), clock/date (237–324).
- Repeated 4 px gaps split each segmented bar; repeated 90 px cells organize the radial metrics.
- Header and icon edges align at x=30–31; metric values and bars align at x=75. This prevents the dense layout from becoming visually noisy.

## Typography

- Large: Rajdhani Medium for `HH:MM:SS`, rendered as final-size digit cells and optically compressed only on the vertical axis.
- Medium: Rajdhani Medium at a 21 px optical height for the date.
- Small: Rajdhani Medium at an 18 px optical height for the top status strip, segmented-bar values, and gauge values.
- Hours, minutes, and dim seconds are separate draw calls. Fixed 37 px advances position two optical dot pairs while preserving tabular stability.

### Font decision

The prototype appears to use a customized squared industrial face. Rajdhani is the closest verified open-source fit: its straight-sided bowls, flat terminals, and rectangular counters reproduce that technical shape language without becoming a segmented display font. The clock uses Medium, vertically compressed to the reference's 41 px optical height. Supporting information uses dedicated 18 px and 21 px optical glyph sets rather than one size with artificial tracking. Warm, ink, and dim variants are pre-colored, avoiding Garmin font substitution, runtime scaling, and clipped glyphs on Venu Sq 2.

The official Google Fonts Rajdhani files are stored in `designer/fonts/` with their SIL Open Font License: <https://github.com/google/fonts/tree/main/ofl/rajdhani>. Run `designer/render-font-assets.sh` after changing type size, weight, or color.

Small and medium glyphs are compiled from a shared typographic pen origin into 32 px-wide cells with 4 px of transparent guard space. Runtime drawing removes that guard from the origin, so every tier shares a stable baseline and left edge while neighboring atlas glyphs can never leak into or be clipped by a crop boundary. Large clock cells are transparent too: their 64×68 containers never erase the gauge layer beneath them.

## Color semantics

- `INK #F1F3E8`: primary numeric information.
- `WARM #C9CBAE`: battery, temperature, steps, stress, and hour/minute time.
- `CYAN #49BBC2`: active minutes and Body Battery.
- `MINT #56D39B`: distance and heart rate.
- `DIM #36383A`: seconds, empty radial arcs, and inactive information.
- `TRACK #202425`: separators and unfilled segmented bars.
- Pure black background preserves AMOLED contrast and power efficiency.

## Shape language

- Segmented bars are 9 px high with a shallow 4 px chamfer; semantic icons and segments are authored as SVG masters and compiled to indexed-alpha PNG resources. This preserves antialiased edges through Garmin's resource compiler.
- Radial metrics use a 6 px stroke and 15 px radius, matching the source's ring-to-clock proportion. Progress begins at 12 o'clock and sweeps clockwise by the actual normalized value; zero progress skips the foreground arc because Garmin treats equal start/end angles as a complete circle.
- Dynamic ring progress remains code-drawn; static icons and segments use final-size raster resources for consistent stroke weight.
- The large clock uses active and inactive colors to distinguish readable time from transient seconds.

## Information model

- Header: battery percentage, cached weather temperature in the user's preferred units, and Bluetooth phone connection.
- Segmented rows: steps, weekly active minutes, and distance.
- Gauges: stress, Body Battery, and current heart rate, separated by two subtle vertical rules.
- Footer: `HH:MM:SS` and numeric date.

## AMOLED behavior

- Active mode renders the full dashboard.
- Always-on mode clears to black and renders only a dim `HH:MM`, shifted by ±2 px over time for burn-in mitigation.
- No fills, graphs, icons, seconds, or timers are used in low-power mode.
