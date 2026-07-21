use std::env;
use std::fs;
use std::path::PathBuf;

use garatch_designer_core::export_project_zip;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut arguments = env::args_os().skip(1);
    let output = arguments
        .next()
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("garatch-wasm-sample.zip"));
    let project_json = if let Some(input) = arguments.next() {
        fs::read_to_string(input)?
    } else {
        serde_json::json!({
        "name": "Garatch Wasm Sample",
        "appId": "0123456789abcdef0123456789abcdef",
        "backgroundColor": "#000000",
        "fontFamily": "barlow-condensed",
        "fontHeights": { "time": 104, "value": 36, "label": 18 },
        "letterSpacing": { "time": 0, "value": 0, "label": 0 },
        "elements": [
            {
                "type": "rectangle",
                "id": "header",
                "x": 24,
                "y": 40,
                "width": 272,
                "height": 2,
                "fillColor": "#333333"
            },
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
                "type": "date",
                "id": "date",
                "x": 160,
                "y": 175,
                "color": "#9B978C",
                "align": "center"
            },
            {
                "type": "steps",
                "id": "steps",
                "x": 80,
                "y": 250,
                "color": "#72D6B2",
                "align": "center"
            },
            {
                "type": "heart-rate",
                "id": "heart-rate",
                "x": 160,
                "y": 250,
                "color": "#E76F51",
                "align": "center"
            },
            {
                "type": "battery",
                "id": "battery",
                "x": 240,
                "y": 250,
                "color": "#E7A74E",
                "align": "center"
            }
        ]
        })
        .to_string()
    };
    let archive = export_project_zip(&project_json).map_err(std::io::Error::other)?;
    fs::write(&output, archive)?;
    println!("wrote {}", output.display());
    Ok(())
}
