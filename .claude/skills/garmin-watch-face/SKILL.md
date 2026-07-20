---
name: garmin-watch-face
description: Build, modify, and debug Garmin Connect IQ watch faces in this repo (Monkey C, Venu SQ 2 AMOLED). Use when creating a new face, editing a *View.mc / *App.mc file, wiring up watch data (time, steps, heart rate, battery, sensor history), handling always-on / low-power mode, or building/running a face in the simulator. Triggers on: watch face, Monkey C, Connect IQ, .mc file, monkey.jungle, onUpdate, onLayout, garatch-*, venusq2, AMOLED always-on.
---

# Garmin Watch Face Development (garatch monorepo)

This repo is a **monorepo of Garmin Connect IQ watch faces** written in **Monkey C**, targeting the **Venu SQ 2** (`venusq2` / `venusq2m`) — a **390×390 AMOLED** device. Each face lives in `faces/<name>/`. The reference/template face is **`garatch-minimal`** — start there when building anything new.

## Golden rules

1. **`onLayout` computes geometry once; `onUpdate` only draws.** Cache width/height, fonts, and Y-anchors in `onLayout`. Never call `getFontHeight`/`getWidth` every frame. See `garatch-minimal/source/GaratchView.mc` — the canonical example.
2. **AMOLED always-on is a hard constraint.** In always-on/low-power mode the face updates once per minute and may light **≤10% of pixels**. Draw a dim, sparse layout in that mode. See `references/amoled-power.md`.
3. **Every face = App + View (+ optional Settings module).** `getInitialView()` returns `[ new <Name>View() ]`. Files are named `<Name>App.mc` / `<Name>View.mc`.
4. **Set colors with `COLOR_TRANSPARENT` background** for text/shapes over the cleared face; clear the whole face to black once at the top of `onUpdate`.
5. **Guard every data read for `null`.** `ActivityMonitor.getInfo()`, `Activity.getActivityInfo()`, sensor samples, and `getSystemStats()` can all return null or null fields.

## Workflow (quick reference)

```sh
make build FACE=garatch-minimal DEVICE=venusq2   # compile → bin/<face>.prg
make run   FACE=garatch-minimal                  # build + launch in simulator
make new   NAME=garatch-foo                       # scaffold a new face (copies blueprint)
make list                                          # list faces
make build-all                                     # build every face
```
Full workflow, jungle/manifest details, and the "create a new face" checklist: `references/build-and-workflow.md`.

## When the task is…

- **Create a new face** → read `references/build-and-workflow.md` (scaffold + wiring checklist) and copy the structure of `templates/MinimalView.mc.txt`.
- **Understand face anatomy / edit rendering** → read `references/face-anatomy.md` (lifecycle, layout-caching pattern, drawing idioms, primitive icons).
- **Wire up watch data** (time, steps, HR, HR history graph, battery, calories, etc.) → read `references/data-and-apis.md`. Note the HR graph in `garatch-minimal` is currently **fake synthetic data** — use `SensorHistory.getHeartRateHistory()` for real samples.
- **Always-on / low-power / burn-in / partial update** → read `references/amoled-power.md`.

## Repo layout

```
faces/<name>/
  manifest.xml          # app id, products, permissions, minSdkVersion
  monkey.jungle         # base.sourcePath = source;../../shared/source
  source/<Name>App.mc   # entry point
  source/<Name>View.mc  # the face (all rendering)
  resources/
    strings/strings.xml       # @Strings.AppName etc.
    drawables/drawables.xml   # launcher_icon.png
    layouts/layout.xml        # usually empty — faces draw in code, not XML layout
    settings/settings.xml     # user-facing settings (Connect IQ app / GCM)
    settings/properties.xml    # backing property defaults
shared/source/          # PixelFont.mc, RoundedRect.mc — shared helpers
Makefile                # build/run orchestration
```

## Official docs (fetch with WebFetch when you need specifics)

- API docs: https://developer.garmin.com/connect-iq/api-docs/
- AMOLED / always-on UX: https://developer.garmin.com/connect-iq/user-experience-guidelines/watch-faces/
- Sensors core topic: https://developer.garmin.com/connect-iq/core-topics/sensors/
- WatchFace class: https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html
