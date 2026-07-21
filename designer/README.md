# Garatch Studio

Garatch Studio is a browser-only visual watch-face editor backed by a small
Rust/WebAssembly core. Svelte and Vite are build-time tooling; the production
editor is static HTML, CSS, JavaScript, and WebAssembly with no Electron,
application server, or Node.js runtime.

The editor builds a typed scene, previews it on a 320×360 canvas, validates it in
WebAssembly, and downloads a complete standalone Garmin Connect IQ project as a
ZIP. Users compile the downloaded project locally with Garmin's official
`monkeyc` tool.

## Current scope

- Venu SQ 2 and Venu SQ 2 Music (shared `venusq2` device profile)
- Fixed 320×360 canvas
- Digital time, date, steps, current heart rate, battery, static labels, and
  rectangles
- Null-safe metric reads
- Sparse always-on time rendering
- One face-wide typeface choice shared by every text layer and the generated
  Garmin project, with 10 bundled families
- Role-based font-height presets and letter spacing for time, values, and labels
- Pretext-backed label wrapping with editable wrap width and line height
- Standalone App/View, manifest, jungle, strings, layouts, drawables, and
  launcher icon
- Dependency-free ZIP writer implemented in Rust

## Build and test

Install Node.js, npm, Rust, and the WebAssembly target, then build both halves:

```sh
rustup target add wasm32-unknown-unknown
make -C designer build
```

Or run the combined check:

```sh
make -C designer check
```

## Open the editor

Build the WASM core and start the local static server:

```sh
make -C designer serve
```

Then open <http://127.0.0.1:4173/designer/web/>. The editor autosaves in the
browser. **Download project** produces a ZIP containing the manifest, jungle,
Monkey C sources, resources, and launcher icon.

## UI architecture

The editor uses Svelte 5 composite components with unidirectional data flow.
`ui/App.svelte` owns project state, persistence, selection, validation, and
export orchestration. The surrounding composites have focused contracts:

- `ComponentPalette.svelte` creates scene elements
- `LayersPanel.svelte` renders and selects the layer stack
- `Stage.svelte` owns canvas rendering, hit testing, and direct manipulation
- `InspectorPanel.svelte` composes property fields and layer actions
- `ProjectHealth.svelte` presents WASM validation and project-level controls

Shared project operations and catalog metadata live in `ui/lib/`. Motion powers
the runtime button and control feedback. DialKit is loaded only by the Vite
development build so spacing, color, and motion values can be tuned in-browser;
it is eliminated from the production static bundle.

Pretext measures text, chooses line breaks, and produces the label line layout.
The canvas then draws those lines with the same BMFont glyph atlases packaged in
the generated Garmin project, keeping the browser preview and simulator output
visually aligned.

For live UI tuning with DialKit:

```sh
make -C designer dev
```

Generate a sample project archive:

```sh
cargo run --manifest-path designer/Cargo.toml \
  --example export_sample -- /tmp/garatch-wasm-sample.zip
```

## Input format

```json
{
  "name": "Wasm Sample",
  "appId": "0123456789abcdef0123456789abcdef",
  "backgroundColor": "#000000",
  "fontFamily": "barlow-condensed",
  "fontHeights": { "time": 104, "value": 36, "label": 18 },
  "letterSpacing": { "time": 0, "value": 0, "label": 0 },
  "elements": [
    {
      "type": "time",
      "id": "main-time",
      "x": 160,
      "y": 120,
      "color": "#FFFFFF",
      "align": "center",
      "format": "device",
      "showSeconds": false
    },
    {
      "type": "steps",
      "id": "steps",
      "x": 160,
      "y": 230,
      "color": "#72D6B2",
      "align": "center"
    }
  ]
}
```

The WebAssembly module exposes a small raw memory ABI: `garatch_alloc`,
`garatch_free`, `garatch_validate`, and `garatch_export_project_zip`. The browser
wrapper in `web/wasm.js` owns encoding, memory copies, and result decoding.
