# Face Anatomy

## The two classes

**`<Name>App.mc`** — thin entry point:
```monkeyc
using Toybox.Application;
class GaratchApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function onStart(state) {}
    function onStop(state) {}
    function getInitialView() { return [ new GaratchView() ]; }
}
function getApp() { return Application.getApp(); }
```

**`<Name>View.mc`** — the face itself, extends `WatchUi.WatchFace`.

## WatchFace lifecycle

| Method | When | What to do |
|---|---|---|
| `initialize()` | once, construction | call `WatchFace.initialize()` |
| `onLayout(dc)` | once, after load | **cache geometry**: width, height, fonts, font heights, Y-anchors |
| `onUpdate(dc)` | every visible tick (per second in high-power; once/min in low-power) | clear + draw everything |
| `onPartialUpdate(dc)` | each of the 59 non-top-of-minute seconds in low-power (if supported) | draw the small always-on delta only (≤10% pixels) |
| `onEnterSleep()` | entering low-power | set a flag; simplify next draw |
| `onExitSleep()` | leaving low-power | clear the flag; request full redraw |
| `onHide()` | face hidden | cleanup |

## The layout-caching pattern (do this)

From `garatch-minimal`. Compute once in `onLayout`, reference in `onUpdate`:

```monkeyc
function onLayout(dc) {
    _w = dc.getWidth();
    _h = dc.getHeight();
    _m = 18;                                   // margin

    _fTime  = Graphics.FONT_SYSTEM_NUMBER_HOT; // big time font
    _fValue = Graphics.FONT_SMALL;
    _fLabel = Graphics.FONT_TINY;

    _hValue = dc.getFontHeight(_fValue);       // cache heights — never per-frame
    _hTime  = dc.getFontHeight(_fTime);

    _timeY  = (_h * 0.35).toNumber();          // Y-anchors as fractions of height
    var timeBottom = _timeY + (_hTime / 2);
    _stepsY = timeBottom + 16;
    _barY   = _stepsY + _hValue + 8;
    _hrY    = _barY + 16;
    _graphY = _h - 26;
}
```

## Drawing idioms

- **Clear once, then draw:** `dc.setColor(BLACK, BLACK); dc.clear();` at the top of `onUpdate`.
- **Transparent backgrounds for content:** `dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT)` before `drawText`/shapes.
- **Justification:** `drawText(x, y, font, str, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER)`. Center the time on `_w/2`; right-align a value at `_w - _m`.
- **Measure to lay out rows:** `dc.getTextWidthInPixels(str, font)` to right-align value+label pairs.
- **Progress bar:** background `fillRectangle` in dark gray, foreground `fillRectangle` scaled by `pct` clamped to [0,1].
- **Primitive icons (no assets):** the minimal face draws walk/heart/battery glyphs from `drawLine`/`drawCircle`/`fillCircle`/`fillRectangle`. Cheap and burn-in friendly. See `drawWalkIcon`, `drawHeartIcon`, `drawBattery` in `GaratchView.mc`.
- **`setPenWidth(n)`** for thicker lines (e.g. graph strokes); reset to 1 after.

## Shared helpers (`shared/source/`)

Pulled in via `monkey.jungle` (`base.sourcePath = source;../../shared/source`):
- **`PixelFont.mc`** — custom pixel-font rendering.
- **`RoundedRect.mc`** — rounded-rectangle drawing helper.

Check these before hand-rolling rounded rects or custom fonts.

## Theme module pattern (optional)

`garatch-minimal` and `garatch-blueprint` ship a `GaratchSettings` module mapping a `theme` property to a color dictionary (`:timeColor`, `:valueColor`, `:background`, …). **Note:** the minimal View currently does *not* consume it — it hardcodes black/white/gray. If you add theming, read `GaratchSettings.getTheme()` in `onLayout`/`onUpdate` and pull colors from the returned dictionary. The `theme` property is wired through `resources/settings/settings.xml` + `properties.xml` so users can pick it in the Connect IQ app.

## Small utilities worth reusing (in the minimal View)

- `formatNumber(val)` — inserts thousands separators (`1,234`).
- `clamp(val, min, max)`.
- `getDayName(dow)` / `getMonthName(m)` — 1-indexed → `"MON"` / `"JAN"` (mind the `-1` indexing off `Gregorian.info`).
