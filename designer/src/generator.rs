use std::collections::HashSet;
use std::fmt::{self, Write};

use serde::{Deserialize, Serialize};

use crate::model::{
    Alignment, DistanceUnit, Element, FontFamily, FontHeights, IconKind, LetterSpacing,
    ProjectSpec, TimeFormat,
};

const WATCH_WIDTH: i32 = 320;
const WATCH_HEIGHT: i32 = 360;
const LAUNCHER_ICON: &[u8] = include_bytes!("../assets/launcher_icon.png");

struct FontAssets {
    time_file: &'static str,
    time_descriptor: &'static [u8],
    time_atlas: &'static [u8],
    value_file: &'static str,
    value_descriptor: &'static [u8],
    value_atlas: &'static [u8],
    label_file: &'static str,
    label_descriptor: &'static [u8],
    label_atlas: &'static [u8],
    license_file: &'static str,
    license: &'static [u8],
}

macro_rules! font_resource {
    ($prefix:literal, $variant:literal) => {
        (
            concat!($prefix, "_", $variant, ".fnt"),
            include_bytes!(concat!("../assets/fonts/", $prefix, "_", $variant, ".fnt"))
                as &'static [u8],
            include_bytes!(concat!("../assets/fonts/", $prefix, "_", $variant, ".png"))
                as &'static [u8],
        )
    };
}

macro_rules! family_assets {
    ($prefix:literal, $license_source:literal, $license_export:literal, $heights:expr) => {{
        let (time_file, time_descriptor, time_atlas) = match $heights.time {
            72 => font_resource!($prefix, "time_72"),
            88 => font_resource!($prefix, "time_88"),
            104 => font_resource!($prefix, "time_104"),
            120 => font_resource!($prefix, "time_120"),
            _ => unreachable!("validated time font height"),
        };
        let (value_file, value_descriptor, value_atlas) = match $heights.value {
            24 => font_resource!($prefix, "value_24"),
            30 => font_resource!($prefix, "value_30"),
            36 => font_resource!($prefix, "value_36"),
            42 => font_resource!($prefix, "value_42"),
            _ => unreachable!("validated value font height"),
        };
        let (label_file, label_descriptor, label_atlas) = match $heights.label {
            14 => font_resource!($prefix, "label_14"),
            18 => font_resource!($prefix, "label_18"),
            22 => font_resource!($prefix, "label_22"),
            26 => font_resource!($prefix, "label_26"),
            _ => unreachable!("validated label font height"),
        };
        FontAssets {
            time_file,
            time_descriptor,
            time_atlas,
            value_file,
            value_descriptor,
            value_atlas,
            label_file,
            label_descriptor,
            label_atlas,
            license_file: $license_export,
            license: include_bytes!(concat!("../assets/fonts/", $license_source)),
        }
    }};
}

fn selected_font_assets(family: FontFamily, heights: FontHeights) -> FontAssets {
    match family {
        FontFamily::BarlowCondensed => {
            family_assets!("garatch", "OFL.txt", "Barlow-OFL.txt", heights)
        }
        FontFamily::Rajdhani => {
            family_assets!("rajdhani", "Rajdhani-OFL.txt", "Rajdhani-OFL.txt", heights)
        }
        FontFamily::RobotoCondensed => family_assets!(
            "roboto_condensed",
            "RobotoCondensed-OFL.txt",
            "RobotoCondensed-OFL.txt",
            heights
        ),
        FontFamily::IbmPlexSansCondensed => family_assets!(
            "ibm_plex_sans_condensed",
            "IBMPlexSansCondensed-OFL.txt",
            "IBMPlexSansCondensed-OFL.txt",
            heights
        ),
        FontFamily::Oswald => {
            family_assets!("oswald", "Oswald-OFL.txt", "Oswald-OFL.txt", heights)
        }
        FontFamily::SairaCondensed => family_assets!(
            "saira_condensed",
            "SairaCondensed-OFL.txt",
            "SairaCondensed-OFL.txt",
            heights
        ),
        FontFamily::ChakraPetch => family_assets!(
            "chakra_petch",
            "ChakraPetch-OFL.txt",
            "ChakraPetch-OFL.txt",
            heights
        ),
        FontFamily::Oxanium => {
            family_assets!("oxanium", "Oxanium-OFL.txt", "Oxanium-OFL.txt", heights)
        }
        FontFamily::SpaceGrotesk => family_assets!(
            "space_grotesk",
            "SpaceGrotesk-OFL.txt",
            "SpaceGrotesk-OFL.txt",
            heights
        ),
        FontFamily::ArchivoNarrow => family_assets!(
            "archivo_narrow",
            "ArchivoNarrow-OFL.txt",
            "ArchivoNarrow-OFL.txt",
            heights
        ),
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct ValidationIssue {
    pub field: String,
    pub message: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct ValidationReport {
    pub valid: bool,
    pub issues: Vec<ValidationIssue>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GeneratedFile {
    pub path: String,
    pub bytes: Vec<u8>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GeneratedProject {
    pub folder_name: String,
    pub files: Vec<GeneratedFile>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum GenerateError {
    InvalidJson(String),
    InvalidSpec(Vec<ValidationIssue>),
}

impl fmt::Display for GenerateError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidJson(message) => write!(formatter, "invalid project JSON: {message}"),
            Self::InvalidSpec(issues) => {
                write!(formatter, "project validation failed")?;
                for issue in issues {
                    write!(formatter, "; {}: {}", issue.field, issue.message)?;
                }
                Ok(())
            }
        }
    }
}

impl std::error::Error for GenerateError {}

pub fn parse_spec(json: &str) -> Result<ProjectSpec, GenerateError> {
    serde_json::from_str(json).map_err(|error| GenerateError::InvalidJson(error.to_string()))
}

pub fn validate_spec(spec: &ProjectSpec) -> ValidationReport {
    let mut issues = Vec::new();

    let name = spec.name.trim();
    if name.is_empty() {
        issue(&mut issues, "name", "must not be empty");
    } else if name.chars().count() > 48 {
        issue(&mut issues, "name", "must be 48 characters or fewer");
    }

    if normalize_app_id(&spec.app_id).is_none() {
        issue(
            &mut issues,
            "appId",
            "must contain exactly 32 hexadecimal digits (hyphens are allowed)",
        );
    }

    if parse_color(&spec.background_color).is_none() {
        issue(
            &mut issues,
            "backgroundColor",
            "must use #RRGGBB hexadecimal notation",
        );
    }

    validate_font_height(
        &mut issues,
        "fontHeights.time",
        spec.font_heights.time,
        &[72, 88, 104, 120],
    );
    validate_font_height(
        &mut issues,
        "fontHeights.value",
        spec.font_heights.value,
        &[24, 30, 36, 42],
    );
    validate_font_height(
        &mut issues,
        "fontHeights.label",
        spec.font_heights.label,
        &[14, 18, 22, 26],
    );
    validate_letter_spacing(&mut issues, "letterSpacing.time", spec.letter_spacing.time);
    validate_letter_spacing(
        &mut issues,
        "letterSpacing.value",
        spec.letter_spacing.value,
    );
    validate_letter_spacing(
        &mut issues,
        "letterSpacing.label",
        spec.letter_spacing.label,
    );

    if spec.elements.is_empty() {
        issue(&mut issues, "elements", "must contain at least one element");
    } else if spec.elements.len() > 64 {
        issue(&mut issues, "elements", "must contain 64 elements or fewer");
    }

    if !spec
        .elements
        .iter()
        .any(|element| matches!(element, Element::Time { .. }))
    {
        issue(
            &mut issues,
            "elements",
            "must contain a time element for the always-on display",
        );
    }

    let mut ids = HashSet::new();
    for (index, element) in spec.elements.iter().enumerate() {
        let field = format!("elements[{index}]");
        let id = element.id().trim();
        if id.is_empty() {
            issue(&mut issues, format!("{field}.id"), "must not be empty");
        } else if !ids.insert(id) {
            issue(
                &mut issues,
                format!("{field}.id"),
                "must be unique within the project",
            );
        }

        let (x, y) = element.origin();
        if !(0..WATCH_WIDTH).contains(&x) {
            issue(
                &mut issues,
                format!("{field}.x"),
                "must be within the 320-pixel canvas",
            );
        }
        if !(0..WATCH_HEIGHT).contains(&y) {
            issue(
                &mut issues,
                format!("{field}.y"),
                "must be within the 360-pixel canvas",
            );
        }
        if parse_color(element.color()).is_none() {
            issue(
                &mut issues,
                format!("{field}.color"),
                "must use #RRGGBB hexadecimal notation",
            );
        }

        match element {
            Element::Label {
                text,
                max_width,
                line_height,
                rendered_lines,
                ..
            } => {
                if text.chars().count() > 64 {
                    issue(
                        &mut issues,
                        format!("{field}.text"),
                        "must be 64 characters or fewer",
                    );
                }
                if text.chars().any(char::is_control) {
                    issue(
                        &mut issues,
                        format!("{field}.text"),
                        "must not contain control characters",
                    );
                }
                if !(20..=320).contains(max_width) {
                    issue(
                        &mut issues,
                        format!("{field}.maxWidth"),
                        "must be between 20 and 320 pixels",
                    );
                }
                if !(8..=80).contains(line_height) {
                    issue(
                        &mut issues,
                        format!("{field}.lineHeight"),
                        "must be between 8 and 80 pixels",
                    );
                }
                if rendered_lines.len() > 8 {
                    issue(
                        &mut issues,
                        format!("{field}.renderedLines"),
                        "must contain 8 lines or fewer",
                    );
                }
            }
            Element::Rectangle {
                width,
                height,
                corner_radius,
                ..
            } => {
                if *width == 0 || *height == 0 {
                    issue(
                        &mut issues,
                        format!("{field}.size"),
                        "width and height must both be greater than zero",
                    );
                }
                if i64::from(x) + i64::from(*width) > i64::from(WATCH_WIDTH)
                    || i64::from(y) + i64::from(*height) > i64::from(WATCH_HEIGHT)
                {
                    issue(
                        &mut issues,
                        format!("{field}.size"),
                        "rectangle must fit inside the 320×360 canvas",
                    );
                }
                if *corner_radius > width.min(height) / 2 {
                    issue(
                        &mut issues,
                        format!("{field}.cornerRadius"),
                        "must not exceed half of the shortest side",
                    );
                }
            }
            Element::Ellipse {
                radius_x, radius_y, ..
            } => {
                if *radius_x == 0 || *radius_y == 0 {
                    issue(
                        &mut issues,
                        format!("{field}.radius"),
                        "both radii must be greater than zero",
                    );
                }
                if i64::from(x) - i64::from(*radius_x) < 0
                    || i64::from(y) - i64::from(*radius_y) < 0
                    || i64::from(x) + i64::from(*radius_x) >= i64::from(WATCH_WIDTH)
                    || i64::from(y) + i64::from(*radius_y) >= i64::from(WATCH_HEIGHT)
                {
                    issue(
                        &mut issues,
                        format!("{field}.radius"),
                        "ellipse must fit inside the 320×360 canvas",
                    );
                }
            }
            Element::Line {
                end_x,
                end_y,
                thickness,
                ..
            } => {
                if !(0..WATCH_WIDTH).contains(end_x) || !(0..WATCH_HEIGHT).contains(end_y) {
                    issue(
                        &mut issues,
                        format!("{field}.end"),
                        "line endpoint must be within the 320×360 canvas",
                    );
                }
                if !(1..=12).contains(thickness) {
                    issue(
                        &mut issues,
                        format!("{field}.thickness"),
                        "must be between 1 and 12 pixels",
                    );
                }
            }
            Element::Icon { size, .. } => {
                if !(12..=96).contains(size) {
                    issue(
                        &mut issues,
                        format!("{field}.size"),
                        "must be between 12 and 96 pixels",
                    );
                }
                let half = i64::from(*size / 2);
                if i64::from(x) - half < 0
                    || i64::from(y) - half < 0
                    || i64::from(x) + half >= i64::from(WATCH_WIDTH)
                    || i64::from(y) + half >= i64::from(WATCH_HEIGHT)
                {
                    issue(
                        &mut issues,
                        format!("{field}.size"),
                        "icon must fit inside the 320×360 canvas",
                    );
                }
            }
            _ => {}
        }
    }

    ValidationReport {
        valid: issues.is_empty(),
        issues,
    }
}

fn validate_font_height(
    issues: &mut Vec<ValidationIssue>,
    field: &str,
    height: u32,
    supported: &[u32],
) {
    if !supported.contains(&height) {
        issue(
            issues,
            field,
            format!(
                "must be one of {}",
                supported
                    .iter()
                    .map(u32::to_string)
                    .collect::<Vec<_>>()
                    .join(", ")
            ),
        );
    }
}

fn validate_letter_spacing(issues: &mut Vec<ValidationIssue>, field: &str, spacing: i32) {
    if !(-2..=6).contains(&spacing) {
        issue(issues, field, "must be between -2 and 6 pixels");
    }
}

pub fn generate_project(spec: &ProjectSpec) -> Result<GeneratedProject, GenerateError> {
    let report = validate_spec(spec);
    if !report.valid {
        return Err(GenerateError::InvalidSpec(report.issues));
    }

    let folder_name = folder_name(&spec.name);
    let class_name = class_name(&spec.name);
    let app_id = normalize_app_id(&spec.app_id).expect("validated app id");
    let fonts = selected_font_assets(spec.font_family, spec.font_heights);
    let files = vec![
        text_file("manifest.xml", manifest_xml(&class_name, &app_id)),
        text_file("monkey.jungle", jungle()),
        text_file(
            format!("source/{class_name}App.mc"),
            app_source(&class_name),
        ),
        text_file(
            format!("source/{class_name}View.mc"),
            view_source(spec, &class_name),
        ),
        text_file("resources/drawables/drawables.xml", drawables_xml()),
        GeneratedFile {
            path: "resources/drawables/launcher_icon.png".to_owned(),
            bytes: LAUNCHER_ICON.to_vec(),
        },
        text_file("resources/strings/strings.xml", strings_xml(&spec.name)),
        text_file("resources/layouts/layout.xml", layout_xml()),
        text_file("resources/fonts/fonts.xml", fonts_xml(&fonts)),
        binary_file(
            format!("resources/fonts/{}", fonts.time_file),
            fonts.time_descriptor,
        ),
        binary_file(
            format!(
                "resources/fonts/{}",
                fonts.time_file.replace(".fnt", ".png")
            ),
            fonts.time_atlas,
        ),
        binary_file(
            format!("resources/fonts/{}", fonts.value_file),
            fonts.value_descriptor,
        ),
        binary_file(
            format!(
                "resources/fonts/{}",
                fonts.value_file.replace(".fnt", ".png")
            ),
            fonts.value_atlas,
        ),
        binary_file(
            format!("resources/fonts/{}", fonts.label_file),
            fonts.label_descriptor,
        ),
        binary_file(
            format!(
                "resources/fonts/{}",
                fonts.label_file.replace(".fnt", ".png")
            ),
            fonts.label_atlas,
        ),
        binary_file(format!("LICENSES/{}", fonts.license_file), fonts.license),
    ];

    Ok(GeneratedProject { folder_name, files })
}

fn text_file(path: impl Into<String>, content: String) -> GeneratedFile {
    GeneratedFile {
        path: path.into(),
        bytes: content.into_bytes(),
    }
}

fn binary_file(path: impl Into<String>, bytes: &[u8]) -> GeneratedFile {
    GeneratedFile {
        path: path.into(),
        bytes: bytes.to_vec(),
    }
}

fn manifest_xml(class_name: &str, app_id: &str) -> String {
    format!(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<iq:manifest xmlns:iq=\"http://www.garmin.com/xml/connectiq\" version=\"3\">\n\
  <iq:application entry=\"{class_name}App\" id=\"{app_id}\" launcherIcon=\"@Drawables.LauncherIcon\" minSdkVersion=\"3.2.0\" name=\"@Strings.AppName\" type=\"watchface\" version=\"1.0.0\">\n\
    <iq:products>\n\
      <iq:product id=\"venusq2\"/>\n\
    </iq:products>\n\
    <iq:languages><iq:language>eng</iq:language></iq:languages>\n\
    <iq:barrels/>\n\
  </iq:application>\n\
</iq:manifest>\n",
        class_name = class_name,
        app_id = app_id
    )
}

fn jungle() -> String {
    "project.manifest = manifest.xml\nbase.sourcePath = source\n".to_owned()
}

fn app_source(class_name: &str) -> String {
    format!(
        "using Toybox.Application;\n\n\
class {class_name}App extends Application.AppBase {{\n\
    function initialize() {{ AppBase.initialize(); }}\n\
    function onStart(state) {{}}\n\
    function onStop(state) {{}}\n\
    function getInitialView() {{ return [ new {class_name}View() ]; }}\n\
}}\n"
    )
}

fn view_source(spec: &ProjectSpec, class_name: &str) -> String {
    let has_date = spec
        .elements
        .iter()
        .any(|element| matches!(element, Element::Date { .. }));
    let has_activity_monitor = spec.elements.iter().any(|element| {
        matches!(
            element,
            Element::Steps { .. } | Element::Calories { .. } | Element::Distance { .. }
        )
    });
    let has_heart_rate = spec
        .elements
        .iter()
        .any(|element| matches!(element, Element::HeartRate { .. }));

    let mut source = String::new();
    if has_heart_rate {
        source.push_str("using Toybox.Activity;\n");
    }
    if has_activity_monitor {
        source.push_str("using Toybox.ActivityMonitor;\n");
    }
    source.push_str("using Toybox.Graphics;\nusing Toybox.System;\n");
    if has_date {
        source.push_str("using Toybox.Time;\nusing Toybox.Time.Gregorian;\n");
    }
    source.push_str("using Toybox.WatchUi;\n\n");

    writeln!(
        source,
        "class {class_name}View extends WatchUi.WatchFace {{"
    )
    .unwrap();
    source.push_str(
        "    private var _fontTime;\n\
    private var _fontValue;\n\
    private var _fontLabel;\n\
    private var _lowPower = false;\n\n\
    function initialize() { WatchFace.initialize(); }\n\n\
    function onLayout(dc) {\n\
        _fontTime = WatchUi.loadResource(Rez.Fonts.FaceTime);\n\
        _fontValue = WatchUi.loadResource(Rez.Fonts.FaceValue);\n\
        _fontLabel = WatchUi.loadResource(Rez.Fonts.FaceLabel);\n\
    }\n\n\
    function drawText(dc, x, y, font, text, justify, spacing) {\n\
        if (spacing == 0) {\n\
            dc.drawText(x, y, font, text, justify | Graphics.TEXT_JUSTIFY_VCENTER);\n\
            return;\n\
        }\n\
        var count = text.length();\n\
        var width = 0;\n\
        for (var i = 0; i < count; i++) {\n\
            width += dc.getTextWidthInPixels(text.substring(i, i + 1), font);\n\
        }\n\
        if (count > 1) { width += spacing * (count - 1); }\n\
        var cursor = x;\n\
        if (justify == Graphics.TEXT_JUSTIFY_CENTER) { cursor -= width / 2; }\n\
        else if (justify == Graphics.TEXT_JUSTIFY_RIGHT) { cursor -= width; }\n\
        for (var j = 0; j < count; j++) {\n\
            var glyph = text.substring(j, j + 1);\n\
            dc.drawText(cursor, y, font, glyph, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);\n\
            cursor += dc.getTextWidthInPixels(glyph, font) + spacing;\n\
        }\n\
    }\n\n\
    function onUpdate(dc) {\n",
    );
    writeln!(
        source,
        "        dc.setColor({}, {});",
        color_code(&spec.background_color),
        color_code(&spec.background_color)
    )
    .unwrap();
    source.push_str(
        "        dc.clear();\n\n\
        if (_lowPower) {\n\
            drawAlwaysOn(dc);\n\
            return;\n\
        }\n",
    );

    for (index, element) in spec.elements.iter().enumerate() {
        source.push('\n');
        source.push_str(&render_element(
            element,
            index,
            "        ",
            spec.letter_spacing,
        ));
    }

    source.push_str(
        "    }\n\n\
    function drawAlwaysOn(dc) {\n",
    );
    if let Some((index, time)) = spec
        .elements
        .iter()
        .enumerate()
        .find(|(_, element)| matches!(element, Element::Time { .. }))
    {
        source.push_str(&render_always_on_time(
            time,
            index,
            spec.letter_spacing.time,
        ));
    }
    source.push_str(
        "    }\n\n\
    function onEnterSleep() { _lowPower = true; }\n\
    function onExitSleep() { _lowPower = false; }\n\
    function onHide() {}\n\
}\n",
    );
    source
}

fn render_element(element: &Element, index: usize, indent: &str, spacing: LetterSpacing) -> String {
    match element {
        Element::Time {
            x,
            y,
            color,
            align,
            format,
            show_seconds,
            ..
        } => render_time(
            index,
            *x,
            *y,
            color,
            *align,
            *format,
            *show_seconds,
            spacing.time,
            indent,
        ),
        Element::Date {
            x, y, color, align, ..
        } => format!(
            "{indent}var date{index} = Gregorian.info(Time.now(), Time.FORMAT_SHORT);\n\
{indent}var dateValue{index} = date{index}.day.format(\"%02d\") + \"/\" + date{index}.month.format(\"%02d\");\n\
{}",
            draw_text(
                *x,
                *y,
                color,
                font_resource(FontRole::Label),
                *align,
                &format!("dateValue{index}"),
                spacing.label,
                indent
            )
        ),
        Element::Steps {
            x, y, color, align, ..
        } => format!(
            "{indent}var activity{index} = ActivityMonitor.getInfo();\n\
{indent}var stepsValue{index} = \"--\";\n\
{indent}if (activity{index} != null && activity{index}.steps != null) {{\n\
{indent}    stepsValue{index} = activity{index}.steps.format(\"%d\");\n\
{indent}}}\n\
{}",
            draw_text(
                *x,
                *y,
                color,
                font_resource(FontRole::Value),
                *align,
                &format!("stepsValue{index}"),
                spacing.value,
                indent
            )
        ),
        Element::HeartRate {
            x, y, color, align, ..
        } => format!(
            "{indent}var heartInfo{index} = Activity.getActivityInfo();\n\
{indent}var heartValue{index} = \"--\";\n\
{indent}if (heartInfo{index} != null && heartInfo{index}.currentHeartRate != null) {{\n\
{indent}    heartValue{index} = heartInfo{index}.currentHeartRate.format(\"%d\");\n\
{indent}}}\n\
{}",
            draw_text(
                *x,
                *y,
                color,
                font_resource(FontRole::Value),
                *align,
                &format!("heartValue{index}"),
                spacing.value,
                indent
            )
        ),
        Element::Battery {
            x, y, color, align, ..
        } => format!(
            "{indent}var stats{index} = System.getSystemStats();\n\
{indent}var batteryValue{index} = \"--\";\n\
{indent}if (stats{index} != null && stats{index}.battery != null) {{\n\
{indent}    batteryValue{index} = stats{index}.battery.toNumber().format(\"%d\") + \"%\";\n\
{indent}}}\n\
{}",
            draw_text(
                *x,
                *y,
                color,
                font_resource(FontRole::Value),
                *align,
                &format!("batteryValue{index}"),
                spacing.value,
                indent
            )
        ),
        Element::Calories {
            x, y, color, align, ..
        } => format!(
            "{indent}var activity{index} = ActivityMonitor.getInfo();\n\
{indent}var caloriesValue{index} = \"--\";\n\
{indent}if (activity{index} != null && activity{index}.calories != null) {{\n\
{indent}    caloriesValue{index} = activity{index}.calories.format(\"%d\");\n\
{indent}}}\n\
{}",
            draw_text(
                *x,
                *y,
                color,
                font_resource(FontRole::Value),
                *align,
                &format!("caloriesValue{index}"),
                spacing.value,
                indent
            )
        ),
        Element::Distance {
            x,
            y,
            color,
            align,
            unit,
            ..
        } => {
            let divisor = match unit {
                DistanceUnit::Kilometers => "100000.0",
                DistanceUnit::Miles => "160934.4",
            };
            format!(
                "{indent}var activity{index} = ActivityMonitor.getInfo();\n\
{indent}var distanceValue{index} = \"--\";\n\
{indent}if (activity{index} != null && activity{index}.distance != null) {{\n\
{indent}    var distanceNumber{index} = activity{index}.distance / {divisor};\n\
{indent}    distanceValue{index} = distanceNumber{index}.format(\"%.1f\");\n\
{indent}}}\n\
{}",
                draw_text(
                    *x,
                    *y,
                    color,
                    font_resource(FontRole::Value),
                    *align,
                    &format!("distanceValue{index}"),
                    spacing.value,
                    indent
                )
            )
        }
        Element::Label {
            x,
            y,
            text,
            color,
            align,
            line_height,
            rendered_lines,
            ..
        } => render_label(
            *x,
            *y,
            text,
            color,
            *align,
            *line_height,
            rendered_lines,
            spacing.label,
            indent,
        ),
        Element::Rectangle {
            x,
            y,
            width,
            height,
            fill_color,
            corner_radius,
            ..
        } => {
            if *corner_radius == 0 {
                format!(
                    "{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillRectangle({x}, {y}, {width}, {height});\n",
                    color_code(fill_color)
                )
            } else {
                format!(
                    "{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillRoundedRectangle({x}, {y}, {width}, {height}, {corner_radius});\n",
                    color_code(fill_color)
                )
            }
        }
        Element::Ellipse {
            x,
            y,
            radius_x,
            radius_y,
            fill_color,
            ..
        } => format!(
            "{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillEllipse({x}, {y}, {radius_x}, {radius_y});\n",
            color_code(fill_color)
        ),
        Element::Line {
            x,
            y,
            end_x,
            end_y,
            color,
            thickness,
            ..
        } => format!(
            "{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.setPenWidth({thickness});\n\
{indent}dc.drawLine({x}, {y}, {end_x}, {end_y});\n\
{indent}dc.setPenWidth(1);\n",
            color_code(color)
        ),
        Element::Icon {
            x,
            y,
            icon,
            size,
            color,
            ..
        } => render_icon(*x, *y, *size, color, *icon, indent),
    }
}

fn render_icon(x: i32, y: i32, size: u32, color: &str, icon: IconKind, indent: &str) -> String {
    let half = i32::try_from(size / 2).unwrap_or(0);
    let quarter = i32::try_from(size / 4).unwrap_or(0);
    let fifth = i32::try_from(size / 5).unwrap_or(0);
    let eighth = i32::try_from(size / 8).unwrap_or(0);
    let color = color_code(color);
    match icon {
        IconKind::Heart => format!(
            "{indent}dc.setColor({color}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillCircle({}, {}, {quarter});\n\
{indent}dc.fillCircle({}, {}, {quarter});\n\
{indent}dc.fillPolygon([[{}, {}], [{}, {}], [{x}, {}]]);\n",
            x - fifth,
            y - eighth,
            x + fifth,
            y - eighth,
            x - half,
            y - eighth,
            x + half,
            y - eighth,
            y + half
        ),
        IconKind::Steps => format!(
            "{indent}dc.setColor({color}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillEllipse({}, {}, {}, {});\n\
{indent}dc.fillEllipse({}, {}, {}, {});\n",
            x - quarter,
            y - quarter,
            eighth,
            quarter,
            x + quarter,
            y + eighth,
            eighth,
            quarter
        ),
        IconKind::Battery => format!(
            "{indent}dc.setColor({color}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.setPenWidth(2);\n\
{indent}dc.drawRectangle({}, {}, {}, {});\n\
{indent}dc.fillRectangle({}, {}, {}, {});\n\
{indent}dc.fillRectangle({}, {}, {}, {});\n\
{indent}dc.setPenWidth(1);\n",
            x - half,
            y - quarter,
            size - 3,
            size / 2,
            x + half - 2,
            y - eighth,
            3,
            size / 4,
            x - half + 4,
            y - quarter + 4,
            size.saturating_sub(11),
            size.saturating_sub(8) / 2
        ),
        IconKind::Flame => format!(
            "{indent}dc.setColor({color}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillPolygon([[{x}, {}], [{}, {}], [{}, {}], [{}, {}], [{}, {}]]);\n",
            y - half,
            x + half,
            y + eighth,
            x + quarter,
            y + half,
            x - quarter,
            y + half,
            x - half,
            y
        ),
        IconKind::Pin => format!(
            "{indent}dc.setColor({color}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillCircle({x}, {}, {quarter});\n\
{indent}dc.fillPolygon([[{}, {}], [{}, {}], [{x}, {}]]);\n",
            y - quarter,
            x - quarter,
            y - eighth,
            x + quarter,
            y - eighth,
            y + half
        ),
        IconKind::Sun => format!(
            "{indent}dc.setColor({color}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillCircle({x}, {y}, {quarter});\n\
{indent}dc.setPenWidth(2);\n\
{indent}dc.drawLine({x}, {}, {x}, {});\n\
{indent}dc.drawLine({x}, {}, {x}, {});\n\
{indent}dc.drawLine({}, {y}, {}, {y});\n\
{indent}dc.drawLine({}, {y}, {}, {y});\n\
{indent}dc.setPenWidth(1);\n",
            y - half,
            y - quarter - 2,
            y + quarter + 2,
            y + half,
            x - half,
            x - quarter - 2,
            x + quarter + 2,
            x + half
        ),
        IconKind::Bolt => format!(
            "{indent}dc.setColor({color}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillPolygon([[{}, {}], [{}, {}], [{}, {y}], [{}, {y}], [{}, {}], [{}, {}]]);\n",
            x + eighth,
            y - half,
            x - half,
            y + eighth,
            x - eighth,
            x - quarter,
            x - eighth,
            y + half,
            x + half,
            y - eighth
        ),
    }
}

#[allow(clippy::too_many_arguments)]
fn render_time(
    index: usize,
    x: i32,
    y: i32,
    color: &str,
    align: Alignment,
    format: TimeFormat,
    show_seconds: bool,
    spacing: i32,
    indent: &str,
) -> String {
    let mut output = format!(
        "{indent}var clock{index} = System.getClockTime();\n\
{indent}var hour{index} = clock{index}.hour;\n"
    );
    match format {
        TimeFormat::Device => {
            writeln!(
                output,
                "{indent}if (!System.getDeviceSettings().is24Hour) {{"
            )
            .unwrap();
            write!(output, "{}", hour_12_conversion(index, indent)).unwrap();
            writeln!(output, "{indent}}}").unwrap();
        }
        TimeFormat::Hour12 => output.push_str(&hour_12_conversion(index, indent)),
        TimeFormat::Hour24 => {}
    }
    write!(
        output,
        "{indent}var timeValue{index} = hour{index}.format(\"%02d\") + \":\" + clock{index}.min.format(\"%02d\")"
    )
    .unwrap();
    if show_seconds {
        write!(output, " + \":\" + clock{index}.sec.format(\"%02d\")").unwrap();
    }
    output.push_str(";\n");
    output.push_str(&draw_text(
        x,
        y,
        color,
        font_resource(FontRole::Time),
        align,
        &format!("timeValue{index}"),
        spacing,
        indent,
    ));
    output
}

fn hour_12_conversion(index: usize, indent: &str) -> String {
    format!(
        "{indent}    if (hour{index} == 0) {{ hour{index} = 12; }}\n\
{indent}    else if (hour{index} > 12) {{ hour{index} -= 12; }}\n"
    )
}

fn render_always_on_time(element: &Element, index: usize, spacing: i32) -> String {
    let Element::Time {
        x,
        y,
        align,
        format,
        ..
    } = element
    else {
        return String::new();
    };
    render_time(
        index + 1000,
        *x,
        *y,
        "#555555",
        *align,
        *format,
        false,
        spacing,
        "        ",
    )
}

#[derive(Clone, Copy)]
enum FontRole {
    Time,
    Value,
    Label,
}

fn font_resource(role: FontRole) -> &'static str {
    match role {
        FontRole::Time => "_fontTime",
        FontRole::Value => "_fontValue",
        FontRole::Label => "_fontLabel",
    }
}

#[allow(clippy::too_many_arguments)]
fn draw_text(
    x: i32,
    y: i32,
    color: &str,
    font: &str,
    align: Alignment,
    value: &str,
    spacing: i32,
    indent: &str,
) -> String {
    format!(
        "{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);\n\
{indent}drawText(dc, {x}, {y}, {}, {value}, {}, {spacing});\n",
        color_code(color),
        font,
        alignment_code(align)
    )
}

#[allow(clippy::too_many_arguments)]
fn render_label(
    x: i32,
    y: i32,
    text: &str,
    color: &str,
    align: Alignment,
    line_height: u32,
    rendered_lines: &[String],
    spacing: i32,
    indent: &str,
) -> String {
    let lines = if rendered_lines.is_empty() {
        vec![text]
    } else {
        rendered_lines.iter().map(String::as_str).collect()
    };
    let line_height = i32::try_from(line_height).expect("validated label line height");
    let start_y = y - ((i32::try_from(lines.len()).unwrap_or(1) - 1) * line_height / 2);
    let mut output = String::new();
    for (line_index, line) in lines.iter().enumerate() {
        output.push_str(&draw_text(
            x,
            start_y + i32::try_from(line_index).unwrap_or(0) * line_height,
            color,
            font_resource(FontRole::Label),
            align,
            &format!("\"{}\"", monkey_string(line)),
            spacing,
            indent,
        ));
    }
    output
}

fn drawables_xml() -> String {
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<drawables>\n\
  <bitmap id=\"LauncherIcon\" filename=\"launcher_icon.png\"/>\n\
</drawables>\n"
        .to_owned()
}

fn fonts_xml(fonts: &FontAssets) -> String {
    format!(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<fonts>\n\
  <font id=\"FaceTime\" filename=\"{}\" antialias=\"true\"/>\n\
  <font id=\"FaceValue\" filename=\"{}\" antialias=\"true\"/>\n\
  <font id=\"FaceLabel\" filename=\"{}\" antialias=\"true\"/>\n\
</fonts>\n",
        fonts.time_file, fonts.value_file, fonts.label_file
    )
}

fn strings_xml(name: &str) -> String {
    format!(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<strings>\n\
  <string id=\"AppName\">{}</string>\n\
</strings>\n",
        xml_escape(name.trim())
    )
}

fn layout_xml() -> String {
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<layouts>\n\
  <layout id=\"WatchFace\"/>\n\
</layouts>\n"
        .to_owned()
}

pub fn folder_name(name: &str) -> String {
    let mut output = String::new();
    let mut pending_separator = false;
    for character in name.trim().chars() {
        if character.is_ascii_alphanumeric() {
            if pending_separator && !output.is_empty() {
                output.push('-');
            }
            output.push(character.to_ascii_lowercase());
            pending_separator = false;
        } else {
            pending_separator = true;
        }
    }
    if output.is_empty() {
        "garatch-face".to_owned()
    } else {
        output
    }
}

pub fn class_name(name: &str) -> String {
    let mut output = String::new();
    for word in name.split(|character: char| !character.is_ascii_alphanumeric()) {
        if word.is_empty() {
            continue;
        }
        let mut characters = word.chars();
        if let Some(first) = characters.next() {
            output.push(first.to_ascii_uppercase());
            for character in characters {
                output.push(character);
            }
        }
    }
    if output.is_empty() {
        output.push_str("GaratchFace");
    } else if output.starts_with(|character: char| character.is_ascii_digit()) {
        output.insert_str(0, "Garatch");
    }
    output
}

fn normalize_app_id(app_id: &str) -> Option<String> {
    let normalized: String = app_id
        .chars()
        .filter(|character| *character != '-')
        .collect();
    if normalized.len() == 32
        && normalized
            .chars()
            .all(|character| character.is_ascii_hexdigit())
    {
        Some(normalized.to_ascii_lowercase())
    } else {
        None
    }
}

fn parse_color(color: &str) -> Option<u32> {
    let hexadecimal = color.strip_prefix('#')?;
    if hexadecimal.len() != 6 {
        return None;
    }
    u32::from_str_radix(hexadecimal, 16).ok()
}

fn color_code(color: &str) -> String {
    format!("0x{:06X}", parse_color(color).expect("validated color"))
}

fn alignment_code(alignment: Alignment) -> &'static str {
    match alignment {
        Alignment::Left => "Graphics.TEXT_JUSTIFY_LEFT",
        Alignment::Center => "Graphics.TEXT_JUSTIFY_CENTER",
        Alignment::Right => "Graphics.TEXT_JUSTIFY_RIGHT",
    }
}

fn monkey_string(value: &str) -> String {
    value
        .replace('\\', "\\\\")
        .replace('"', "\\\"")
        .replace('\n', "\\n")
        .replace('\r', "\\r")
}

fn xml_escape(value: &str) -> String {
    value
        .replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&apos;")
}

fn issue(issues: &mut Vec<ValidationIssue>, field: impl Into<String>, message: impl Into<String>) {
    issues.push(ValidationIssue {
        field: field.into(),
        message: message.into(),
    });
}
