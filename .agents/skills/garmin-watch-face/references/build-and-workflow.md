# Build & Workflow

## Toolchain

- **Monkey C compiler:** `monkeyc` (from the Connect IQ SDK, on PATH)
- **Simulator runner:** `monkeydo` / `connectiq`
- **Signing key:** `developer_key.der` at repo root (also `.pem`). Required for every build (`-y`). **Never regenerate or lose it** — losing it means you can't update published apps.

## Make targets (see `Makefile`)

| Command | What it does |
|---|---|
| `make build FACE=<name> DEVICE=venusq2` | Compile `faces/<name>` → `bin/<name>.prg` (with `-g` debug). |
| `make run FACE=<name>` | Build then `monkeydo` into the simulator. |
| `make simulator` | Launch the Connect IQ simulator (`connectiq &`). |
| `make new NAME=<name>` | Scaffold a new face by copying `garatch-blueprint`'s manifest + jungle. |
| `make list` | List faces. |
| `make build-all` | Build every face in `faces/`. |
| `make watch FACE=<name>` | Rebuild+run on file change (needs `fswatch`). |
| `make clean` / `clean-all` | Remove build artifacts. |

Defaults: `FACE=garatch-blueprint`, `DEVICE=venusq2`, `DEV_KEY=developer_key.der`.

## Venu SQ 2 device-id quirk

- Declare both `<iq:product id="venusq2"/>` and `<iq:product id="venusq2m"/>` in the manifest.
- Compile and run both variants with `DEVICE=venusq2` in the installed SDK.
- Do not use `monkeyc -d venusq2m`: SDK 8.2.0 rejects it as an invalid compiler device id even though `resources/device-reference/venusq2m` exists. The two variants share the 320×360 target used here.

## Raw compile (what `make build` runs)

```sh
monkeyc -d venusq2 -f faces/<name>/monkey.jungle -o bin/<name>.prg -y developer_key.der -g
```

## Creating a new face — checklist

`make new NAME=garatch-foo` gives you a skeleton but leaves wiring to do. To go from `garatch-minimal` instead (recommended — it's the clean reference), do this:

1. **Copy the whole face dir:** `cp -r faces/garatch-minimal faces/garatch-foo`.
2. **Rename source classes/files** consistently. If you keep the `Garatch` prefix you can leave `GaratchApp`/`GaratchView`; otherwise rename `<Name>App.mc` + `<Name>View.mc` and update `entry="<Name>App"` in `manifest.xml` and the `class <Name>View` / `new <Name>View()` references.
3. **`manifest.xml`:** generate a **new unique app `id`** (a fresh UUID — never reuse another face's id) and update `name="@Strings.AppName"`. Keep `type="watchface"`, `minSdkVersion="3.2.0"`, products `venusq2`/`venusq2m`.
4. **`monkey.jungle`:** leave as-is — `base.sourcePath = source;../../shared/source` pulls in shared helpers.
5. **`resources/strings/strings.xml`:** set `AppName` and any labels.
6. **`resources/drawables/`:** provide a `launcher_icon.png` (referenced by `drawables.xml`).
7. **Permissions:** declare what you read in `manifest.xml`. Current minimal face uses `UserProfile` + `SensorHistory`. Add `<iq:uses-permission id="..."/>` for anything else (e.g. weather).
8. **Build:** `make build FACE=garatch-foo DEVICE=venusq2` then `make run FACE=garatch-foo DEVICE=venusq2`.

## manifest.xml anatomy

```xml
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
  <iq:application entry="GaratchApp" id="<UUID>" launcherIcon="@Drawables.LauncherIcon"
                  minSdkVersion="3.2.0" name="@Strings.AppName" type="watchface" version="1.0.0">
    <iq:products>
      <iq:product id="venusq2"/>
      <iq:product id="venusq2m"/>
    </iq:products>
    <iq:permissions>
      <iq:uses-permission id="UserProfile"/>
      <iq:uses-permission id="SensorHistory"/>
    </iq:permissions>
    <iq:languages><iq:language>eng</iq:language></iq:languages>
    <iq:barrels/>
  </iq:application>
</iq:manifest>
```

## Simulator validation

1. Run `make build FACE=<name> DEVICE=venusq2`, then `monkeydo bin/<name>.prg venusq2`.
2. Inspect the face inside the Venu SQ 2 bezel. A generated 320×360 mockup is a design reference, not proof that Garmin text metrics align.
3. Inject daily values through **Simulation → Activity Monitoring → Set Activity Monitor Info**. Test a long step count/goal and non-zero calories.
4. Test populated SensorHistory values and clean `--` fallbacks. In SDK 8.2.0, starting **Simulation → Activity Data** did not populate `Activity.getActivityInfo().currentHeartRate` for a watch face; verify live HR on hardware rather than weakening the null guard.
5. Trigger low power, confirm the sparse always-on render, then wake the watch and confirm the full face returns.
6. Save a simulator screenshot with the face so design review uses the compiled result.

The simulator status bar reports runtime memory (for example `18.7/123.8kB`). Do not confuse the signed `.prg` file size with the watch-face runtime memory limit.

## Debugging

- Build with `-g` (Make already does) to get `bin/<name>.prg.debug.xml`.
- Use `System.println(...)` for logging; output shows in the simulator console.
- The simulator can inject many values through its Simulation and Settings menus, but not every current sensor value is synthesised for watch faces. Preserve null-safe UI.
