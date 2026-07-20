# AMOLED, Always-On & Low-Power Mode

The **Venu SQ 2 is AMOLED**. This changes the rules versus MIP/memory-in-pixel faces.

## The three states

1. **High-power (active):** watch raised / recently interacted. `onUpdate` called ~once per second. Full richness allowed.
2. **Low-power, always-on OFF:** screen off. Nothing to draw.
3. **Low-power, always-on ON:** the display stays on dimly. This is the constrained mode below.

## Always-on constraints (hard limits)

- `onUpdate` is called **once per minute** (top of the minute).
- If partial updates are supported, `onPartialUpdate(dc)` is called for the **other 59 seconds**.
- Each low-power draw may light at most **~10% of the display's pixels** (burn-in + power budget). Exceeding the **power budget** skips the draw and calls `onPowerBudgetExceeded()`.
- **No timers or animations** in low-power mode.

## What to do

Track sleep state and branch your rendering:

```monkeyc
private var _lowPower = false;

function onEnterSleep() { _lowPower = true;  WatchUi.requestUpdate(); }
function onExitSleep()  { _lowPower = false; WatchUi.requestUpdate(); }

function onUpdate(dc) {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    if (_lowPower) {
        drawAlwaysOn(dc);   // dim, sparse: time only, thin strokes, no fills
    } else {
        drawFull(dc);       // time + steps + HR + graph + battery
    }
}
```

`drawAlwaysOn` guidance:
- Draw **time only** (maybe minute-resolution), no seconds hand/animation.
- Use **dim colors** (dark gray, not full white) and **thin strokes / outlines** instead of filled shapes — filled areas blow the 10% pixel budget fast.
- Keep it **small and centered**; avoid large bright blocks.
- **Shift position slightly over time** (burn-in mitigation) if you draw the same pixels for long stretches — some devices do this for you, but a few px of jitter helps.

## Partial updates (optional, advanced)

To update something (e.g. a seconds indicator) each second in always-on:
- Implement `onPartialUpdate(dc)` and declare a `WatchFaceDelegate` if needed.
- Clip to the smallest possible region with `dc.setClip(x, y, w, h)` and draw only that.
- Keep it minuscule — it counts against the same power budget.
- Handle `onPowerBudgetExceeded(powerInfo)` by shrinking what you draw.

## Testing always-on in the simulator

Simulator menu: toggle **Always On** / **Low Power Mode** and **Do Not Sleep** to exercise `onEnterSleep`/`onExitSleep`/`onPartialUpdate` and watch for `onPowerBudgetExceeded`.

## Current status in this repo

`garatch-minimal` has **empty** `onEnterSleep`/`onExitSleep`/`onHide` and no `onPartialUpdate` — it draws the full rich layout in every state. Adding the low-power branch above is the main outstanding AMOLED-correctness improvement.

## Reference

- AMOLED UX guidelines: https://developer.garmin.com/connect-iq/user-experience-guidelines/watch-faces/
- Make a face for AMOLED: https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-make-a-watch-face-for-amoled-products/
- WatchFace API: https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html
- WatchFaceDelegate: https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFaceDelegate.html
