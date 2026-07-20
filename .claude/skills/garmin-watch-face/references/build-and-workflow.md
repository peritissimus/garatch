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
8. **Build:** `make build FACE=garatch-foo` then `make run FACE=garatch-foo`.

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

## Debugging

- Build with `-g` (Make already does) to get `bin/<name>.prg.debug.xml`.
- Use `System.println(...)` for logging; output shows in the simulator console.
- The simulator can inject test data (HR, steps, battery) via its Settings/Data menus — essential for testing metrics that read as null on desktop.
