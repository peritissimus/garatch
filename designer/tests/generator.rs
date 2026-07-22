use garatch_designer_core::{
    GenerateError, TimeFormat, export_project_zip, generate_project, parse_spec,
    validate_project_json, validate_spec,
};

fn sample_json() -> String {
    serde_json::json!({
        "name": "Wasm Test",
        "appId": "01234567-89ab-cdef-0123-456789abcdef",
        "backgroundColor": "#000000",
        "fontFamily": "barlow-condensed",
        "fontHeights": { "time": 104, "value": 36, "label": 18 },
        "letterSpacing": { "time": 0, "value": 0, "label": 0 },
        "elements": [
            {
                "type": "time",
                "id": "time",
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
                "y": 220,
                "color": "#72D6B2",
                "align": "center"
            },
            {
                "type": "heart-rate",
                "id": "heart",
                "x": 160,
                "y": 260,
                "color": "#E76F51",
                "align": "center"
            }
        ]
    })
    .to_string()
}

#[test]
fn validates_and_generates_a_complete_project() {
    let spec = parse_spec(&sample_json()).unwrap();
    assert!(validate_spec(&spec).valid);

    let project = generate_project(&spec).unwrap();
    assert_eq!(project.folder_name, "wasm-test");
    assert_eq!(project.files.len(), 16);

    let paths: Vec<&str> = project
        .files
        .iter()
        .map(|file| file.path.as_str())
        .collect();
    assert!(paths.contains(&"manifest.xml"));
    assert!(paths.contains(&"monkey.jungle"));
    assert!(paths.contains(&"source/WasmTestApp.mc"));
    assert!(paths.contains(&"source/WasmTestView.mc"));
    assert!(paths.contains(&"resources/drawables/launcher_icon.png"));
    assert!(paths.contains(&"resources/fonts/fonts.xml"));
    assert!(paths.contains(&"resources/fonts/garatch_time_104.fnt"));
    assert!(paths.contains(&"resources/fonts/garatch_time_104.png"));
    assert!(paths.contains(&"resources/fonts/garatch_value_36.fnt"));
    assert!(paths.contains(&"resources/fonts/garatch_label_18.fnt"));
    assert!(paths.contains(&"LICENSES/Barlow-OFL.txt"));
    assert!(!paths.contains(&"resources/fonts/rajdhani_time_104.fnt"));
    assert!(!paths.contains(&"LICENSES/Rajdhani-OFL.txt"));

    let manifest = project
        .files
        .iter()
        .find(|file| file.path == "manifest.xml")
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();
    assert!(manifest.contains("<iq:product id=\"venusq2\"/>"));
    assert!(!manifest.contains("venusq2m"));

    let font_resources = project
        .files
        .iter()
        .find(|file| file.path == "resources/fonts/fonts.xml")
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();
    assert!(font_resources.contains("id=\"FaceTime\" filename=\"garatch_time_104.fnt\""));
    assert!(font_resources.contains("id=\"FaceValue\" filename=\"garatch_value_36.fnt\""));
    assert!(font_resources.contains("id=\"FaceLabel\" filename=\"garatch_label_18.fnt\""));

    let view = project
        .files
        .iter()
        .find(|file| file.path.ends_with("View.mc"))
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();
    assert!(view.contains("ActivityMonitor.getInfo()"));
    assert!(view.contains("activity1 != null && activity1.steps != null"));
    assert!(view.contains("currentHeartRate != null"));
    assert!(view.contains("function drawAlwaysOn(dc)"));
    assert!(view.contains("0x555555"));
    assert!(view.contains("WatchUi.loadResource(Rez.Fonts.FaceTime)"));
    assert!(view.contains("WatchUi.loadResource(Rez.Fonts.FaceValue)"));
    assert!(view.contains("_fontTime, timeValue0"));
    assert!(view.contains("_fontValue, stepsValue1"));
    assert!(!view.contains("Graphics.FONT_SYSTEM_NUMBER_HOT"));
}

#[test]
fn exports_only_the_face_wide_selected_font_family() {
    let mut project: serde_json::Value = serde_json::from_str(&sample_json()).unwrap();
    project["fontFamily"] = "oxanium".into();
    project["fontHeights"] = serde_json::json!({ "time": 88, "value": 30, "label": 22 });
    let spec = parse_spec(&project.to_string()).unwrap();
    let generated = generate_project(&spec).unwrap();
    let paths: Vec<&str> = generated
        .files
        .iter()
        .map(|file| file.path.as_str())
        .collect();
    let view = generated
        .files
        .iter()
        .find(|file| file.path.ends_with("View.mc"))
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();

    assert_eq!(generated.files.len(), 16);
    assert!(paths.contains(&"resources/fonts/oxanium_time_88.fnt"));
    assert!(paths.contains(&"resources/fonts/oxanium_value_30.png"));
    assert!(paths.contains(&"resources/fonts/oxanium_label_22.fnt"));
    assert!(paths.contains(&"LICENSES/Oxanium-OFL.txt"));
    assert!(!paths.contains(&"resources/fonts/garatch_time_88.fnt"));
    assert!(view.contains("_fontTime, timeValue0"));
    assert!(view.contains("_fontValue, stepsValue1"));
    assert!(view.contains("_fontValue, heartValue2"));
}

#[test]
fn exports_pretext_lines_and_letter_spacing() {
    let mut project: serde_json::Value = serde_json::from_str(&sample_json()).unwrap();
    project["letterSpacing"]["label"] = 2.into();
    project["elements"]
        .as_array_mut()
        .unwrap()
        .push(serde_json::json!({
            "type": "label",
            "id": "wrapped-label",
            "x": 160,
            "y": 80,
            "text": "HELLO WORLD",
            "color": "#FFFFFF",
            "align": "center",
            "maxWidth": 80,
            "lineHeight": 24,
            "renderedLines": ["HELLO", "WORLD"]
        }));
    let generated = generate_project(&parse_spec(&project.to_string()).unwrap()).unwrap();
    let view = generated
        .files
        .iter()
        .find(|file| file.path.ends_with("View.mc"))
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();

    assert!(view.contains("text.substring(i, i + 1)"));
    assert!(view.contains("drawText(dc, 160, 68, _fontLabel, \"HELLO\""));
    assert!(view.contains("drawText(dc, 160, 92, _fontLabel, \"WORLD\""));
    assert!(view.contains("Graphics.TEXT_JUSTIFY_CENTER, 2);"));
}

#[test]
fn exports_activity_metrics_and_shape_primitives() {
    let mut project: serde_json::Value = serde_json::from_str(&sample_json()).unwrap();
    project["elements"].as_array_mut().unwrap().extend([
        serde_json::json!({
            "type": "calories",
            "id": "calories",
            "x": 80,
            "y": 300,
            "color": "#E5AD59",
            "align": "center"
        }),
        serde_json::json!({
            "type": "distance",
            "id": "distance",
            "x": 240,
            "y": 300,
            "color": "#78A6D6",
            "align": "center",
            "unit": "miles"
        }),
        serde_json::json!({
            "type": "ellipse",
            "id": "ellipse",
            "x": 160,
            "y": 180,
            "radiusX": 40,
            "radiusY": 24,
            "fillColor": "#27312D"
        }),
        serde_json::json!({
            "type": "line",
            "id": "line",
            "x": 40,
            "y": 250,
            "endX": 280,
            "endY": 250,
            "color": "#72D6B2",
            "thickness": 2
        }),
    ]);

    let generated = generate_project(&parse_spec(&project.to_string()).unwrap()).unwrap();
    let view = generated
        .files
        .iter()
        .find(|file| file.path.ends_with("View.mc"))
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();

    assert!(view.contains("activity3.calories.format(\"%d\")"));
    assert!(view.contains("activity4.distance / 160934.4"));
    assert!(view.contains("distanceNumber4.format(\"%.1f\")"));
    assert!(view.contains("dc.fillEllipse(160, 180, 40, 24)"));
    assert!(view.contains("dc.setPenWidth(2)"));
    assert!(view.contains("dc.drawLine(40, 250, 280, 250)"));
    assert!(view.contains("dc.setPenWidth(1)"));
}

#[test]
fn exports_phosphor_icon_resources_and_draw_calls() {
    let mut project: serde_json::Value = serde_json::from_str(&sample_json()).unwrap();
    for (index, icon) in ["heart", "steps", "battery", "flame", "pin", "sun", "bolt"]
        .iter()
        .enumerate()
    {
        project["elements"]
            .as_array_mut()
            .unwrap()
            .push(serde_json::json!({
                "type": "icon",
                "id": format!("icon-{icon}"),
                "x": 40 + (index as i32 * 38),
                "y": 320,
                "icon": icon,
                "style": if index % 2 == 1 || *icon == "battery" { "outline" } else { "filled" },
                "size": 24,
                "color": "#72D6B2"
            }));
    }
    project["elements"]
        .as_array_mut()
        .unwrap()
        .push(serde_json::json!({
            "type": "icon",
            "id": "icon-steps-filled",
            "x": 40,
            "y": 285,
            "icon": "steps",
            "style": "filled",
            "size": 24,
            "color": "#72D6B2"
        }));
    let spec = parse_spec(&project.to_string()).unwrap();
    assert!(validate_spec(&spec).valid);
    let generated = generate_project(&spec).unwrap();
    let view = generated
        .files
        .iter()
        .find(|file| file.path.ends_with("View.mc"))
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();
    let paths: Vec<&str> = generated
        .files
        .iter()
        .map(|file| file.path.as_str())
        .collect();
    let drawables = generated
        .files
        .iter()
        .find(|file| file.path == "resources/drawables/drawables.xml")
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();

    assert!(view.contains("new Graphics.AffineTransform()"));
    assert!(view.contains(".scale(0.250000, 0.250000)"));
    assert!(view.contains("dc.drawBitmap2"));
    assert!(view.contains(":tintColor => 0x72D6B2"));
    assert!(view.contains(":filterMode => Graphics.FILTER_MODE_BILINEAR"));
    assert!(view.contains("Rez.Drawables.IconHeartFilled"));
    assert!(view.contains("Rez.Drawables.IconStepsOutline"));
    assert!(drawables.contains("id=\"IconHeartFilled\" filename=\"heart_filled.png\""));
    assert!(drawables.contains("id=\"IconStepsOutline\" filename=\"steps_outline.png\""));
    assert!(paths.contains(&"resources/drawables/heart_filled.png"));
    assert!(paths.contains(&"resources/drawables/steps_outline.png"));
    assert!(paths.contains(&"LICENSES/Phosphor-MIT.txt"));
    assert!(!paths.contains(&"resources/drawables/heart_outline.png"));
}

#[test]
fn exports_dynamic_component_representations() {
    let mut project: serde_json::Value = serde_json::from_str(&sample_json()).unwrap();
    project["elements"][0]["representation"] = "stacked".into();
    project["elements"][1]["representation"] = "goal-ring".into();
    project["elements"][2]["representation"] = "zone-gauge".into();
    project["elements"][2]["progressMax"] = 180.into();
    project["elements"].as_array_mut().unwrap().extend([
        serde_json::json!({
            "type": "date", "id": "date", "x": 160, "y": 190,
            "color": "#FFFFFF", "align": "center", "representation": "stacked"
        }),
        serde_json::json!({
            "type": "battery", "id": "battery", "x": 240, "y": 300,
            "color": "#FFFFFF", "align": "center", "representation": "icon-value"
        }),
        serde_json::json!({
            "type": "calories", "id": "calories", "x": 80, "y": 300,
            "color": "#E5AD59", "align": "center", "representation": "progress-bar"
        }),
        serde_json::json!({
            "type": "distance", "id": "distance", "x": 160, "y": 330,
            "color": "#78A6D6", "align": "center", "unit": "kilometers",
            "representation": "progress-bar"
        }),
        serde_json::json!({
            "type": "stress", "id": "stress", "x": 160, "y": 290,
            "color": "#B6A0E8", "align": "center", "representation": "history-graph"
        }),
    ]);

    let spec = parse_spec(&project.to_string()).unwrap();
    assert!(validate_spec(&spec).valid);
    let generated = generate_project(&spec).unwrap();
    let view = generated
        .files
        .iter()
        .find(|file| file.path.ends_with("View.mc"))
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();
    let paths: Vec<&str> = generated
        .files
        .iter()
        .map(|file| file.path.as_str())
        .collect();

    assert!(view.contains("hourValue0"));
    assert!(view.contains("minuteValue0"));
    assert!(view.contains("date3.day.format(\"%02d\")"));
    assert!(view.contains("var ringProgress1 = stepsNumber1.toFloat()"));
    assert!(view.contains("Rez.Drawables.IconBatteryFilled"));
    assert!(view.contains("var zoneRatio2 = ((heartNumber2.toFloat() / 180) - 0.5) / 0.5"));
    assert!(view.contains("fillRoundedRectangle(116, 345, 88, 6, 3)"));
    assert!(view.contains("drawHistoryGraph(dc, _stressHistory"));
    assert!(view.contains("SensorHistory.getStressHistory"));
    assert!(paths.contains(&"resources/drawables/battery_filled.png"));
    let manifest = generated
        .files
        .iter()
        .find(|file| file.path == "manifest.xml")
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();
    assert!(manifest.contains("uses-permission id=\"SensorHistory\""));
}

#[test]
fn exports_extended_time_and_date_representations() {
    let mut project: serde_json::Value = serde_json::from_str(&sample_json()).unwrap();
    project["elements"][0]["representation"] = "analog-digital".into();
    project["elements"][0]["showSeconds"] = true.into();
    project["elements"].as_array_mut().unwrap().extend([
        serde_json::json!({
            "type": "date", "id": "date-full", "x": 160, "y": 210,
            "color": "#FFFFFF", "align": "center", "representation": "full-date"
        }),
        serde_json::json!({
            "type": "date", "id": "date-calendar", "x": 250, "y": 250,
            "color": "#78A6D6", "align": "center", "representation": "calendar"
        }),
    ]);

    let spec = parse_spec(&project.to_string()).unwrap();
    assert!(validate_spec(&spec).valid);
    let generated = generate_project(&spec).unwrap();
    let view = generated
        .files
        .iter()
        .find(|file| file.path.ends_with("View.mc"))
        .map(|file| String::from_utf8(file.bytes.clone()).unwrap())
        .unwrap();

    assert!(view.contains("using Toybox.Math;"));
    assert!(view.contains("for (var dialMarker0 = 0; dialMarker0 < 12; dialMarker0++)"));
    assert!(view.contains("var hourAngle0 = Math.toRadians"));
    assert!(view.contains("var secondAngle0 = Math.toRadians"));
    assert!(view.contains("var fullDateValue3 = weekdayValue3"));
    assert!(view.contains("dc.drawRoundedRectangle(219, 218, 62, 64, 8)"));
    assert!(view.contains("date4.day.format(\"%02d\")"));
}

#[test]
fn rejects_representation_that_does_not_fit_the_dynamic_type() {
    let mut project: serde_json::Value = serde_json::from_str(&sample_json()).unwrap();
    project["elements"][0]["representation"] = "icon-value".into();
    let spec = parse_spec(&project.to_string()).unwrap();
    let report = validate_spec(&spec);

    assert!(!report.valid);
    assert!(
        report
            .issues
            .iter()
            .any(|issue| issue.field == "elements[0].representation")
    );
}

#[test]
fn reports_invalid_ids_colors_and_missing_time() {
    let json = serde_json::json!({
        "name": "Broken",
        "appId": "not-an-app-id",
        "backgroundColor": "black",
        "elements": [
            {
                "type": "label",
                "id": "label",
                "x": 999,
                "y": 10,
                "text": "hello",
                "color": "white"
            }
        ]
    })
    .to_string();
    let spec = parse_spec(&json).unwrap();
    let report = validate_spec(&spec);
    assert!(!report.valid);
    assert!(report.issues.len() >= 4);
    assert!(matches!(
        generate_project(&spec),
        Err(GenerateError::InvalidSpec(_))
    ));
}

#[test]
fn returns_machine_readable_validation_results() {
    let report: serde_json::Value =
        serde_json::from_str(&validate_project_json("not json")).unwrap();
    assert_eq!(report["valid"], false);
    assert_eq!(report["issues"][0]["field"], "$");
}

#[test]
fn exports_classic_zip_bytes() {
    let archive = export_project_zip(&sample_json()).unwrap();
    assert!(archive.starts_with(&0x0403_4b50u32.to_le_bytes()));
    assert!(
        archive
            .windows(16)
            .any(|bytes| bytes == b"wasm-test/source")
    );
    assert!(
        archive
            .windows(4)
            .any(|bytes| bytes == 0x0605_4b50u32.to_le_bytes())
    );
}

#[test]
fn accepts_browser_clock_format_values() {
    assert_eq!(
        serde_json::from_str::<TimeFormat>("\"hour12\"").unwrap(),
        TimeFormat::Hour12
    );
    assert_eq!(
        serde_json::from_str::<TimeFormat>("\"hour24\"").unwrap(),
        TimeFormat::Hour24
    );
}
