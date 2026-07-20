---
name: garmin-watch-face
description: >-
  Build, modify, and debug Garmin Connect IQ watch faces in this repo (Monkey C,
  Venu SQ 2 AMOLED). Use when creating a new face, editing a View.mc or App.mc
  file, wiring up watch data such as time, steps, heart rate, battery, weather,
  SpO2, Body Battery, stress, or sensor history, implementing custom BMFont
  typography, handling always-on or low-power mode, or building and inspecting a
  face in the Garmin simulator. Triggers include watch face, Monkey C, Connect IQ,
  .mc, monkey.jungle, onUpdate, onLayout, garatch, venusq2, and AMOLED always-on.
---

# Garmin Watch Face Development (garatch monorepo)

This repo is a **monorepo of Garmin Connect IQ watch faces** written in **Monkey C**, targeting the **Venu SQ 2** — a **320×360 rectangular AMOLED** device. Compile and simulate with device id `venusq2`; keep products `venusq2` and `venusq2m` in the manifest for standard and Music variants. Each face lives in `faces/<name>/`. The reference/template face is **`garatch-minimal`** — start there when building anything new.

## Golden rules

1. **`onLayout` computes static geometry; `onUpdate` reads data and draws.** Cache width/height, fonts, column centers, and fixed anchors in `onLayout`. Measure text during `onUpdate` only when a changing value/unit pair requires dynamic centering. See `garatch-minimal/source/GaratchView.mc` for the base pattern and `references/typography-and-layout.md` for the exception.
2. **AMOLED always-on is a hard constraint.** In always-on/low-power mode the face updates once per minute and may light **≤10% of pixels**. Draw a dim, sparse layout in that mode. See `references/amoled-power.md`.
3. **Every face = App + View (+ optional Settings module).** `getInitialView()` returns `[ new <Name>View() ]`. Files are named `<Name>App.mc` / `<Name>View.mc`.
4. **Set colors with `COLOR_TRANSPARENT` background** for text/shapes over the cleared face; clear the whole face to black once at the top of `onUpdate`.
5. **Guard every data read for `null`.** `ActivityMonitor.getInfo()`, `Activity.getActivityInfo()`, sensor samples, and `getSystemStats()` can all return null or null fields.
6. **Design at the target device's real aspect ratio.** For Venu SQ 2, mockups and screenshots must be exactly 320×360. Confirm dimensions from the installed `Devices/venusq2/compiler.json` or Garmin Device Reference—never infer them from another Venu model.
7. **Typography must be validated in the Garmin simulator.** Browser/image mockup fonts do not predict Garmin system-font metrics. For a distinctive face, use filtered custom BMFont resources and validate realistic longest values. The tested Barlow Condensed role recipe and optical-alignment pattern are in `references/typography-and-layout.md`.
8. **Treat simulator nulls as a required state.** Current heart rate can remain null even when steps, Body Battery, stress, and SpO2 are populated. Render `--` cleanly and verify live sensors on hardware. See `references/data-and-apis.md`.

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
- **Design, typography, custom fonts, or mockup matching** → read `references/typography-and-layout.md`; validate a 320×360 mockup and then the compiled simulator render with realistic and null data.
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
