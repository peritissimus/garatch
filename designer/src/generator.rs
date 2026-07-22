use std::collections::HashSet;
use std::fmt::{self, Write};

use serde::{Deserialize, Serialize};

use crate::model::{
    Alignment, DistanceUnit, Element, FontFamily, FontHeights, IconKind, IconStyle, LetterSpacing,
    ProjectSpec, Representation, TimeFormat,
};

const WATCH_WIDTH: i32 = 320;
const WATCH_HEIGHT: i32 = 360;
const LAUNCHER_ICON: &[u8] = include_bytes!("../assets/launcher_icon.png");
const PHOSPHOR_LICENSE: &[u8] = include_bytes!("../assets/icons/Phosphor-MIT.txt");

struct IconAsset {
    kind: IconKind,
    style: IconStyle,
    file_name: &'static str,
    bytes: &'static [u8],
}

macro_rules! icon_asset {
    ($kind:ident, $style:ident, $id:literal, $file:literal) => {
        IconAsset {
            kind: IconKind::$kind,
            style: IconStyle::$style,
            file_name: $file,
            bytes: include_bytes!(concat!("../assets/icons/", $file)),
        }
    };
}

const ICON_ASSETS: &[IconAsset] = &[
    icon_asset!(Heart, Filled, "IconHeartFilled", "heart_filled.png"),
    icon_asset!(Heart, Outline, "IconHeartOutline", "heart_outline.png"),
    icon_asset!(Steps, Filled, "IconStepsFilled", "steps_filled.png"),
    icon_asset!(Steps, Outline, "IconStepsOutline", "steps_outline.png"),
    icon_asset!(Battery, Filled, "IconBatteryFilled", "battery_filled.png"),
    icon_asset!(
        Battery,
        Outline,
        "IconBatteryOutline",
        "battery_outline.png"
    ),
    icon_asset!(Flame, Filled, "IconFlameFilled", "flame_filled.png"),
    icon_asset!(Flame, Outline, "IconFlameOutline", "flame_outline.png"),
    icon_asset!(Pin, Filled, "IconPinFilled", "pin_filled.png"),
    icon_asset!(Pin, Outline, "IconPinOutline", "pin_outline.png"),
    icon_asset!(Sun, Filled, "IconSunFilled", "sun_filled.png"),
    icon_asset!(Sun, Outline, "IconSunOutline", "sun_outline.png"),
    icon_asset!(Bolt, Filled, "IconBoltFilled", "bolt_filled.png"),
    icon_asset!(Bolt, Outline, "IconBoltOutline", "bolt_outline.png"),
    icon_asset!(Stress, Filled, "IconStressFilled", "stress_filled.png"),
    icon_asset!(Stress, Outline, "IconStressOutline", "stress_outline.png"),
];

fn selected_icon_asset(kind: IconKind, style: IconStyle) -> &'static IconAsset {
    ICON_ASSETS
        .iter()
        .find(|asset| asset.kind == kind && asset.style == style)
        .expect("all icon variants are embedded")
}

fn selected_icon_assets(spec: &ProjectSpec) -> Vec<&'static IconAsset> {
    ICON_ASSETS
        .iter()
        .filter(|asset| {
            spec.elements.iter().any(|element| match element {
                Element::Icon { icon, style, .. } => *icon == asset.kind && *style == asset.style,
                Element::Steps { representation, .. } => {
                    *representation == Representation::Icon
                        && asset.kind == IconKind::Steps
                        && asset.style == IconStyle::Filled
                }
                Element::HeartRate { representation, .. } => {
                    *representation == Representation::Icon
                        && asset.kind == IconKind::Heart
                        && asset.style == IconStyle::Filled
                }
                Element::Stress { representation, .. } => {
                    *representation == Representation::Icon
                        && asset.kind == IconKind::Stress
                        && asset.style == IconStyle::Filled
                }
                Element::Battery { representation, .. } => {
                    *representation == Representation::Icon
                        && asset.kind == IconKind::Battery
                        && asset.style == IconStyle::Filled
                }
                Element::Calories { representation, .. } => {
                    *representation == Representation::Icon
                        && asset.kind == IconKind::Flame
                        && asset.style == IconStyle::Filled
                }
                Element::Distance { representation, .. } => {
                    *representation == Representation::Icon
                        && asset.kind == IconKind::Pin
                        && asset.style == IconStyle::Filled
                }
                _ => false,
            })
        })
        .collect()
}

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
        FontFamily::Dseg7Classic => {
            family_assets!("dseg7_classic", "DSEG-OFL.txt", "DSEG-OFL.txt", heights)
        }
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
            Element::Time { representation, .. } => {
                if !matches!(
                    representation,
                    Representation::Value
                        | Representation::Stacked
                        | Representation::Split
                        | Representation::Analog
                        | Representation::AnalogDigital
                        | Representation::SecondsRing
                ) {
                    issue(
                        &mut issues,
                        format!("{field}.representation"),
                        "is not a supported time representation",
                    );
                }
            }
            Element::Date { representation, .. } => {
                if !matches!(
                    representation,
                    Representation::Value
                        | Representation::Stacked
                        | Representation::Weekday
                        | Representation::MonthDay
                        | Representation::FullDate
                        | Representation::DateYear
                        | Representation::Calendar
                ) {
                    issue(
                        &mut issues,
                        format!("{field}.representation"),
                        "is not a supported date representation",
                    );
                }
            }
            Element::Steps {
                representation,
                progress_max,
                ..
            }
            | Element::Battery {
                representation,
                progress_max,
                ..
            }
            | Element::Calories {
                representation,
                progress_max,
                ..
            }
            | Element::Distance {
                representation,
                progress_max,
                ..
            } => {
                if !matches!(
                    representation,
                    Representation::Value
                        | Representation::Icon
                        | Representation::ProgressBar
                        | Representation::GoalRing
                ) {
                    issue(
                        &mut issues,
                        format!("{field}.representation"),
                        "must be value, icon, progress-bar, or goal-ring for goal metrics",
                    );
                }
                if progress_max.is_some_and(|maximum| maximum <= 0.0 || maximum > 1_000_000.0) {
                    issue(
                        &mut issues,
                        format!("{field}.progressMax"),
                        "must be greater than zero and no more than 1000000",
                    );
                }
            }
            Element::HeartRate {
                representation,
                progress_max,
                ..
            } => {
                if !matches!(
                    representation,
                    Representation::Value
                        | Representation::Icon
                        | Representation::ZoneGauge
                        | Representation::HistoryGraph
                ) {
                    issue(
                        &mut issues,
                        format!("{field}.representation"),
                        "must be value, icon, zone-gauge, or history-graph for heart rate",
                    );
                }
                if progress_max.is_some_and(|maximum| maximum <= 0.0 || maximum > 300.0) {
                    issue(
                        &mut issues,
                        format!("{field}.progressMax"),
                        "must be greater than zero and no more than 300",
                    );
                }
            }
            Element::Stress { representation, .. } => {
                if !matches!(
                    representation,
                    Representation::Value
                        | Representation::Icon
                        | Representation::ZoneGauge
                        | Representation::HistoryGraph
                ) {
                    issue(
                        &mut issues,
                        format!("{field}.representation"),
                        "must be value, icon, zone-gauge, or history-graph for stress",
                    );
                }
            }
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
    let needs_sensor_history = spec.elements.iter().any(|element| {
        matches!(element, Element::Stress { .. })
            || matches!(
                element,
                Element::HeartRate {
                    representation: Representation::HistoryGraph,
                    ..
                }
            )
    });
    // Time uses the primary family; value + label use the secondary family
    // (which falls back to the primary when unset).
    let primary_fonts = selected_font_assets(spec.font_family, spec.font_heights);
    let secondary_family = spec.font_family_secondary.unwrap_or(spec.font_family);
    let secondary_fonts = selected_font_assets(secondary_family, spec.font_heights);
    let fonts = FontAssets {
        time_file: primary_fonts.time_file,
        time_descriptor: primary_fonts.time_descriptor,
        time_atlas: primary_fonts.time_atlas,
        value_file: secondary_fonts.value_file,
        value_descriptor: secondary_fonts.value_descriptor,
        value_atlas: secondary_fonts.value_atlas,
        label_file: secondary_fonts.label_file,
        label_descriptor: secondary_fonts.label_descriptor,
        label_atlas: secondary_fonts.label_atlas,
        license_file: primary_fonts.license_file,
        license: primary_fonts.license,
    };
    let icon_assets = selected_icon_assets(spec);
    let mut files = vec![
        text_file(
            "manifest.xml",
            manifest_xml(&class_name, &app_id, needs_sensor_history),
        ),
        text_file("monkey.jungle", jungle()),
        text_file(
            format!("source/{class_name}App.mc"),
            app_source(&class_name),
        ),
        text_file(
            format!("source/{class_name}View.mc"),
            view_source(spec, &class_name),
        ),
        text_file("resources/drawables/drawables.xml", drawables_xml(spec)),
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

    if secondary_fonts.license_file != fonts.license_file {
        files.push(binary_file(
            format!("LICENSES/{}", secondary_fonts.license_file),
            secondary_fonts.license,
        ));
    }

    if !icon_assets.is_empty() {
        files.push(binary_file("LICENSES/Phosphor-MIT.txt", PHOSPHOR_LICENSE));
    }
    for asset in icon_assets {
        files.push(binary_file(
            format!("resources/drawables/{}", asset.file_name),
            asset.bytes,
        ));
    }

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

fn manifest_xml(class_name: &str, app_id: &str, needs_sensor_history: bool) -> String {
    let permissions = if needs_sensor_history {
        "    <iq:permissions>\n      <iq:uses-permission id=\"SensorHistory\"/>\n    </iq:permissions>\n"
    } else {
        ""
    };
    format!(
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<iq:manifest xmlns:iq=\"http://www.garmin.com/xml/connectiq\" version=\"3\">\n\
  <iq:application entry=\"{class_name}App\" id=\"{app_id}\" launcherIcon=\"@Drawables.LauncherIcon\" minSdkVersion=\"3.2.0\" name=\"@Strings.AppName\" type=\"watchface\" version=\"1.0.0\">\n\
    <iq:products>\n\
      <iq:product id=\"venusq2\"/>\n\
    </iq:products>\n\
{permissions}\
    <iq:languages><iq:language>eng</iq:language></iq:languages>\n\
    <iq:barrels/>\n\
  </iq:application>\n\
</iq:manifest>\n",
        class_name = class_name,
        app_id = app_id,
        permissions = permissions,
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
            Element::Steps { .. }
                | Element::Stress { .. }
                | Element::Calories { .. }
                | Element::Distance { .. }
        )
    });
    let has_heart_rate = spec
        .elements
        .iter()
        .any(|element| matches!(element, Element::HeartRate { .. }));
    let has_stress = spec
        .elements
        .iter()
        .any(|element| matches!(element, Element::Stress { .. }));
    let has_heart_history = spec.elements.iter().any(|element| {
        matches!(
            element,
            Element::HeartRate {
                representation: Representation::HistoryGraph,
                ..
            }
        )
    });
    let has_sensor_history = has_stress || has_heart_history;

    let mut source = String::new();
    if has_heart_rate {
        source.push_str("using Toybox.Activity;\n");
    }
    if has_activity_monitor {
        source.push_str("using Toybox.ActivityMonitor;\n");
    }
    if has_sensor_history {
        source.push_str("using Toybox.SensorHistory;\n");
    }
    source.push_str("using Toybox.Graphics;\nusing Toybox.Math;\nusing Toybox.System;\n");
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
    }\n\n",
    );
    if has_sensor_history {
        source.push_str("    private var _historyStamp = -1;\n");
        if has_heart_history {
            source.push_str("    private var _heartHistory = [];\n");
        }
        if has_stress {
            source.push_str(
                "    private var _stressHistory = [];\n    private var _stressValue = null;\n",
            );
        }
        source.push_str("\n    function refreshHistoryData() {\n        var historyClock = System.getClockTime();\n        var historyStamp = (historyClock.hour * 60) + historyClock.min;\n        if (historyStamp == _historyStamp) { return; }\n        _historyStamp = historyStamp;\n");
        if has_heart_history {
            source.push_str("        _heartHistory = [];\n        try {\n            if ((Toybox has :SensorHistory) && (SensorHistory has :getHeartRateHistory)) {\n                var heartIterator = SensorHistory.getHeartRateHistory({ :period => 24, :order => SensorHistory.ORDER_NEWEST_FIRST });\n                if (heartIterator != null) {\n                    var heartSample = heartIterator.next();\n                    while (heartSample != null && _heartHistory.size() < 24) {\n                        if (heartSample.data != null) { _heartHistory.add(heartSample.data); }\n                        heartSample = heartIterator.next();\n                    }\n                }\n            }\n        } catch (heartHistoryError) {}\n");
        }
        if has_stress {
            source.push_str("        _stressHistory = [];\n        _stressValue = null;\n        try {\n            if ((Toybox has :SensorHistory) && (SensorHistory has :getStressHistory)) {\n                var stressIterator = SensorHistory.getStressHistory({ :period => 24, :order => SensorHistory.ORDER_NEWEST_FIRST });\n                if (stressIterator != null) {\n                    var stressSample = stressIterator.next();\n                    while (stressSample != null && _stressHistory.size() < 24) {\n                        if (stressSample.data != null) {\n                            if (_stressValue == null) { _stressValue = stressSample.data; }\n                            _stressHistory.add(stressSample.data);\n                        }\n                        stressSample = stressIterator.next();\n                    }\n                }\n            }\n        } catch (stressHistoryError) {}\n");
        }
        source.push_str("    }\n\n    function smoothedHistorySample(samples, pointIndex) {\n        var sourceIndex = samples.size() - 1 - pointIndex;\n        var sampleTotal = samples[sourceIndex];\n        var sampleCount = 1;\n        if (sourceIndex > 0) { sampleTotal += samples[sourceIndex - 1]; sampleCount += 1; }\n        if (sourceIndex > 1) { sampleTotal += samples[sourceIndex - 2]; sampleCount += 1; }\n        if (sourceIndex + 1 < samples.size()) { sampleTotal += samples[sourceIndex + 1]; sampleCount += 1; }\n        if (sourceIndex + 2 < samples.size()) { sampleTotal += samples[sourceIndex + 2]; sampleCount += 1; }\n        return sampleTotal.toFloat() / sampleCount;\n    }\n\n    function drawHistoryGraph(dc, samples, graphX, graphY, graphWidth, graphHeight, graphColor) {\n        if (samples == null || samples.size() < 2) { return; }\n        var graphMin = smoothedHistorySample(samples, 0);\n        var graphMax = graphMin;\n        for (var graphIndex = 1; graphIndex < samples.size(); graphIndex++) {\n            var graphValue = smoothedHistorySample(samples, graphIndex);\n            if (graphValue < graphMin) { graphMin = graphValue; }\n            if (graphValue > graphMax) { graphMax = graphValue; }\n        }\n        var graphRange = graphMax - graphMin;\n        if (graphRange < 1) { graphRange = 1; }\n        dc.setColor(graphColor, Graphics.COLOR_TRANSPARENT);\n        dc.setPenWidth(2);\n        var previousX = graphX;\n        var previousY = graphY + graphHeight;\n        for (var pointIndex = 0; pointIndex < samples.size(); pointIndex++) {\n            var sampleValue = smoothedHistorySample(samples, pointIndex);\n            var pointX = graphX + ((pointIndex * graphWidth) / (samples.size() - 1));\n            var pointY = graphY + graphHeight - (((sampleValue - graphMin) * graphHeight) / graphRange);\n            if (pointIndex > 0) { dc.drawLine(previousX, previousY, pointX, pointY); }\n            previousX = pointX;\n            previousY = pointY;\n        }\n        dc.setPenWidth(1);\n    }\n\n");
    }
    source.push_str("    function onUpdate(dc) {\n");
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
    if has_sensor_history {
        source.push_str("        refreshHistoryData();\n");
    }

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
            representation,
            ..
        } => render_time(
            index,
            *x,
            *y,
            color,
            *align,
            *format,
            *show_seconds,
            *representation,
            spacing.time,
            indent,
        ),
        Element::Date {
            x,
            y,
            color,
            align,
            representation,
            ..
        } => render_date(
            index,
            *x,
            *y,
            color,
            *align,
            *representation,
            spacing.label,
            indent,
        ),
        Element::Steps {
            x,
            y,
            color,
            align,
            representation,
            progress_max,
            ..
        } => format!(
            "{indent}var activity{index} = ActivityMonitor.getInfo();\n\
{indent}var stepsValue{index} = \"--\";\n\
{indent}var stepsNumber{index} = 0;\n\
{indent}var stepsGoal{index} = 10000;\n\
{indent}if (activity{index} != null && activity{index}.steps != null) {{\n\
{indent}    stepsNumber{index} = activity{index}.steps;\n\
{indent}    stepsValue{index} = activity{index}.steps.format(\"%d\");\n\
{indent}    if (activity{index}.stepGoal != null && activity{index}.stepGoal > 0) {{ stepsGoal{index} = activity{index}.stepGoal; }}\n\
{indent}}}\n\
{}",
            render_metric_display(
                index,
                *x,
                *y,
                color,
                *align,
                &format!("stepsValue{index}"),
                &format!("stepsNumber{index}"),
                &progress_max_expression(*progress_max, &format!("stepsGoal{index}")),
                *representation,
                IconKind::Steps,
                spacing.value,
                indent
            )
        ),
        Element::HeartRate {
            x,
            y,
            color,
            align,
            representation,
            progress_max,
            ..
        } => format!(
            "{indent}var heartInfo{index} = Activity.getActivityInfo();\n\
{indent}var heartValue{index} = \"--\";\n\
{indent}var heartNumber{index} = 0;\n\
{indent}if (heartInfo{index} != null && heartInfo{index}.currentHeartRate != null) {{\n\
{indent}    heartNumber{index} = heartInfo{index}.currentHeartRate;\n\
{indent}    heartValue{index} = heartInfo{index}.currentHeartRate.format(\"%d\");\n\
{indent}}}\n\
{}",
            match representation {
                Representation::ZoneGauge => render_zone_gauge(
                    index,
                    *x,
                    *y,
                    color,
                    *align,
                    &format!("heartNumber{index}"),
                    &progress_max_expression(*progress_max, "200"),
                    0.5,
                    indent,
                ),
                Representation::HistoryGraph => render_history_display(
                    *x,
                    *y,
                    color,
                    *align,
                    &format!("heartValue{index}"),
                    "_heartHistory",
                    spacing.value,
                    indent,
                ),
                _ => render_metric_display(
                    index,
                    *x,
                    *y,
                    color,
                    *align,
                    &format!("heartValue{index}"),
                    &format!("heartNumber{index}"),
                    &progress_max_expression(*progress_max, "200"),
                    *representation,
                    IconKind::Heart,
                    spacing.value,
                    indent,
                ),
            }
        ),
        Element::Stress {
            x,
            y,
            color,
            align,
            representation,
            ..
        } => format!(
            "{indent}var stressInfo{index} = ActivityMonitor.getInfo();\n\
{indent}var stressNumber{index} = _stressValue;\n\
{indent}if (stressInfo{index} != null && (stressInfo{index} has :stressScore) && stressInfo{index}.stressScore != null) {{ stressNumber{index} = stressInfo{index}.stressScore; }}\n\
{indent}var stressValue{index} = stressNumber{index} == null ? \"--\" : stressNumber{index}.format(\"%d\");\n\
{}",
            match representation {
                Representation::ZoneGauge => render_zone_gauge(
                    index,
                    *x,
                    *y,
                    color,
                    *align,
                    &format!("stressNumber{index} == null ? 0 : stressNumber{index}"),
                    "100",
                    0.0,
                    indent,
                ),
                Representation::HistoryGraph => render_history_display(
                    *x,
                    *y,
                    color,
                    *align,
                    &format!("stressValue{index}"),
                    "_stressHistory",
                    spacing.value,
                    indent,
                ),
                _ => render_metric_display(
                    index,
                    *x,
                    *y,
                    color,
                    *align,
                    &format!("stressValue{index}"),
                    &format!("stressNumber{index} == null ? 0 : stressNumber{index}"),
                    "100",
                    *representation,
                    IconKind::Stress,
                    spacing.value,
                    indent,
                ),
            }
        ),
        Element::Battery {
            x,
            y,
            color,
            align,
            representation,
            progress_max,
            ..
        } => format!(
            "{indent}var stats{index} = System.getSystemStats();\n\
{indent}var batteryValue{index} = \"--\";\n\
{indent}var batteryNumber{index} = 0;\n\
{indent}if (stats{index} != null && stats{index}.battery != null) {{\n\
{indent}    batteryNumber{index} = stats{index}.battery;\n\
{indent}    batteryValue{index} = stats{index}.battery.toNumber().format(\"%d\") + \"%\";\n\
{indent}}}\n\
{}",
            render_metric_display(
                index,
                *x,
                *y,
                color,
                *align,
                &format!("batteryValue{index}"),
                &format!("batteryNumber{index}"),
                &progress_max_expression(*progress_max, "100"),
                *representation,
                IconKind::Battery,
                spacing.value,
                indent
            )
        ),
        Element::Calories {
            x,
            y,
            color,
            align,
            representation,
            progress_max,
            ..
        } => format!(
            "{indent}var activity{index} = ActivityMonitor.getInfo();\n\
{indent}var caloriesValue{index} = \"--\";\n\
{indent}var caloriesNumber{index} = 0;\n\
{indent}if (activity{index} != null && activity{index}.calories != null) {{\n\
{indent}    caloriesNumber{index} = activity{index}.calories;\n\
{indent}    caloriesValue{index} = activity{index}.calories.format(\"%d\");\n\
{indent}}}\n\
{}",
            render_metric_display(
                index,
                *x,
                *y,
                color,
                *align,
                &format!("caloriesValue{index}"),
                &format!("caloriesNumber{index}"),
                &progress_max_expression(*progress_max, "500"),
                *representation,
                IconKind::Flame,
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
            representation,
            progress_max,
            ..
        } => {
            let divisor = match unit {
                DistanceUnit::Kilometers => "100000.0",
                DistanceUnit::Miles => "160934.4",
            };
            format!(
                "{indent}var activity{index} = ActivityMonitor.getInfo();\n\
{indent}var distanceValue{index} = \"--\";\n\
{indent}var distanceNumber{index} = 0.0;\n\
{indent}if (activity{index} != null && activity{index}.distance != null) {{\n\
{indent}    distanceNumber{index} = activity{index}.distance / {divisor};\n\
{indent}    distanceValue{index} = distanceNumber{index}.format(\"%.1f\");\n\
{indent}}}\n\
{}",
                render_metric_display(
                    index,
                    *x,
                    *y,
                    color,
                    *align,
                    &format!("distanceValue{index}"),
                    &format!("distanceNumber{index}"),
                    &progress_max_expression(*progress_max, "10.0"),
                    *representation,
                    IconKind::Pin,
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
            style,
            size,
            color,
            ..
        } => render_icon(index, *x, *y, *size, color, *icon, *style, indent),
    }
}

#[allow(clippy::too_many_arguments)]
fn render_icon(
    index: usize,
    x: i32,
    y: i32,
    size: u32,
    color: &str,
    icon: IconKind,
    style: IconStyle,
    indent: &str,
) -> String {
    let half = i32::try_from(size / 2).expect("validated icon size");
    let _ = (icon, style, color);
    format!(
        "{indent}var iconBitmap{index} = WatchUi.loadResource(Rez.Drawables.Icon{index});\n\
{indent}if (dc has :drawBitmap2) {{\n\
{indent}    dc.drawBitmap2({}, {}, iconBitmap{index}, {{ :tintColor => {} }});\n\
{indent}}} else {{\n\
{indent}    dc.drawBitmap({}, {}, iconBitmap{index});\n\
{indent}}}\n",
        x - half,
        y - half,
        color_code(color),
        x - half,
        y - half,
    )
}

fn progress_max_expression(maximum: Option<f64>, fallback: &str) -> String {
    maximum
        .map(|value| value.to_string())
        .unwrap_or_else(|| fallback.to_owned())
}

#[allow(clippy::too_many_arguments)]
fn render_metric_display(
    index: usize,
    x: i32,
    y: i32,
    color: &str,
    align: Alignment,
    value: &str,
    numeric_value: &str,
    maximum: &str,
    representation: Representation,
    icon: IconKind,
    spacing: i32,
    indent: &str,
) -> String {
    match representation {
        Representation::Icon => {
            let _ = icon;
            let left = match align {
                Alignment::Left => format!("{x}"),
                Alignment::Center => format!("{x} - 9"),
                Alignment::Right => format!("{x} - 18"),
            };
            format!(
                "{indent}var metricLeft{index} = {left};\n\
{indent}var metricBitmap{index} = WatchUi.loadResource(Rez.Drawables.Icon{index});\n\
{indent}if (dc has :drawBitmap2) {{\n\
{indent}    dc.drawBitmap2(metricLeft{index}, {}, metricBitmap{index}, {{ :tintColor => {} }});\n\
{indent}}} else {{\n\
{indent}    dc.drawBitmap(metricLeft{index}, {}, metricBitmap{index});\n\
{indent}}}\n",
                y - 9,
                color_code(color),
                y - 9
            )
        }
        Representation::ProgressBar => {
            let left = match align {
                Alignment::Left => x,
                Alignment::Center => x - 44,
                Alignment::Right => x - 88,
            };
            format!(
                "{}{indent}var progress{index} = {numeric_value}.toFloat() / {maximum};\n\
{indent}if (progress{index} < 0.0) {{ progress{index} = 0.0; }}\n\
{indent}else if (progress{index} > 1.0) {{ progress{index} = 1.0; }}\n\
{indent}var progressWidth{index} = (progress{index} * 88).toNumber();\n\
{indent}dc.setColor(0x242725, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillRoundedRectangle({left}, {}, 88, 6, 3);\n\
{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);\n\
{indent}if (progressWidth{index} > 0) {{ dc.fillRoundedRectangle({left}, {}, progressWidth{index}, 6, 3); }}\n",
                draw_text(
                    x,
                    y - 11,
                    color,
                    font_resource(FontRole::Value),
                    align,
                    value,
                    spacing,
                    indent,
                ),
                y + 15,
                color_code(color),
                y + 15,
            )
        }
        Representation::GoalRing => {
            let left = match align {
                Alignment::Left => x,
                Alignment::Center => x - 44,
                Alignment::Right => x - 88,
            };
            format!(
                "{indent}var ringProgress{index} = {numeric_value}.toFloat() / {maximum};\n\
{indent}if (ringProgress{index} < 0.0) {{ ringProgress{index} = 0.0; }}\n\
{indent}else if (ringProgress{index} > 1.0) {{ ringProgress{index} = 1.0; }}\n\
{indent}dc.setColor(0x242725, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.setPenWidth(4);\n\
{indent}dc.drawCircle({}, {y}, 18);\n\
{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.drawArc({}, {y}, 18, Graphics.ARC_CLOCKWISE, -90, -90 + (ringProgress{index} * 360).toNumber());\n\
{indent}dc.setPenWidth(1);\n\
{indent}drawText(dc, {}, {y}, _fontValue, {value}, Graphics.TEXT_JUSTIFY_LEFT, {spacing});\n",
                left + 20,
                color_code(color),
                left + 20,
                left + 44,
            )
        }
        _ => draw_text(
            x,
            y,
            color,
            font_resource(FontRole::Value),
            align,
            value,
            spacing,
            indent,
        ),
    }
}

#[allow(clippy::too_many_arguments)]
fn render_zone_gauge(
    index: usize,
    x: i32,
    y: i32,
    color: &str,
    align: Alignment,
    numeric_value: &str,
    maximum: &str,
    zone_floor: f64,
    indent: &str,
) -> String {
    let left = match align {
        Alignment::Left => x,
        Alignment::Center => x - 52,
        Alignment::Right => x - 104,
    };
    format!(
        "{indent}var zoneRatio{index} = (({numeric_value}.toFloat() / {maximum}) - {zone_floor}) / {};\n\
{indent}if (zoneRatio{index} < 0.0) {{ zoneRatio{index} = 0.0; }}\n\
{indent}else if (zoneRatio{index} > 1.0) {{ zoneRatio{index} = 1.0; }}\n\
{indent}var zoneColors{index} = [0x5AC8FA, 0x72D6B2, 0xE5AD59, 0xEF7E74, 0xB8566F];\n\
{indent}for (var zoneIndex{index} = 0; zoneIndex{index} < 5; zoneIndex{index}++) {{\n\
{indent}    dc.setColor(zoneColors{index}[zoneIndex{index}], Graphics.COLOR_TRANSPARENT);\n\
{indent}    dc.fillRoundedRectangle({left} + (zoneIndex{index} * 21), {}, 19, 6, 3);\n\
{indent}}}\n\
{indent}var zoneMarker{index} = {left} + (zoneRatio{index} * 103).toNumber();\n\
{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.fillRectangle(zoneMarker{index} - 1, {}, 3, 12);\n",
        1.0 - zone_floor,
        y - 3,
        color_code(color),
        y - 6,
    )
}

#[allow(clippy::too_many_arguments)]
fn render_history_display(
    x: i32,
    y: i32,
    color: &str,
    align: Alignment,
    value: &str,
    samples: &str,
    spacing: i32,
    indent: &str,
) -> String {
    let left = match align {
        Alignment::Left => x,
        Alignment::Center => x - 52,
        Alignment::Right => x - 104,
    };
    format!(
        "{}{indent}dc.setColor(0x242725, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.drawLine({left}, {}, {}, {});\n\
{indent}drawHistoryGraph(dc, {samples}, {left}, {}, 104, 30, {});\n",
        draw_text(
            x,
            y - 18,
            color,
            font_resource(FontRole::Value),
            align,
            value,
            spacing,
            indent,
        ),
        y + 32,
        left + 104,
        y + 32,
        y + 2,
        color_code(color),
    )
}

#[allow(clippy::too_many_arguments)]
fn render_date(
    index: usize,
    x: i32,
    y: i32,
    color: &str,
    align: Alignment,
    representation: Representation,
    spacing: i32,
    indent: &str,
) -> String {
    let mut output = format!(
        "{indent}var date{index} = Gregorian.info(Time.now(), Time.FORMAT_SHORT);\n\
{indent}var dateDays{index} = [\"SUN\", \"MON\", \"TUE\", \"WED\", \"THU\", \"FRI\", \"SAT\"];\n\
{indent}var dateMonths{index} = [\"JAN\", \"FEB\", \"MAR\", \"APR\", \"MAY\", \"JUN\", \"JUL\", \"AUG\", \"SEP\", \"OCT\", \"NOV\", \"DEC\"];\n\
{indent}var weekdayValue{index} = dateDays{index}[date{index}.day_of_week - 1];\n\
{indent}var monthValue{index} = dateMonths{index}[date{index}.month - 1];\n\
{indent}var dateValue{index} = date{index}.day.format(\"%02d\") + \"/\" + date{index}.month.format(\"%02d\");\n"
    );
    match representation {
        Representation::Stacked => {
            output.push_str(&draw_text(
                x,
                y - 10,
                color,
                font_resource(FontRole::Label),
                align,
                &format!("date{index}.day.format(\"%02d\")"),
                spacing,
                indent,
            ));
            output.push_str(&draw_text(
                x,
                y + 10,
                color,
                font_resource(FontRole::Label),
                align,
                &format!("date{index}.month.format(\"%02d\")"),
                spacing,
                indent,
            ));
        }
        Representation::Weekday => output.push_str(&draw_text(
            x,
            y,
            color,
            font_resource(FontRole::Label),
            align,
            &format!("weekdayValue{index}"),
            spacing,
            indent,
        )),
        Representation::MonthDay => {
            writeln!(output, "{indent}var monthDayValue{index} = monthValue{index} + \" \" + date{index}.day.format(\"%02d\");").unwrap();
            output.push_str(&draw_text(
                x,
                y,
                color,
                font_resource(FontRole::Label),
                align,
                &format!("monthDayValue{index}"),
                spacing,
                indent,
            ));
        }
        Representation::FullDate => {
            writeln!(output, "{indent}var fullDateValue{index} = weekdayValue{index} + \", \" + monthValue{index} + \" \" + date{index}.day.format(\"%02d\");").unwrap();
            output.push_str(&draw_text(
                x,
                y,
                color,
                font_resource(FontRole::Label),
                align,
                &format!("fullDateValue{index}"),
                spacing,
                indent,
            ));
        }
        Representation::DateYear => {
            writeln!(output, "{indent}var dateYearValue{index} = date{index}.day.format(\"%02d\") + \" \" + monthValue{index} + \" \" + date{index}.year.format(\"%04d\");").unwrap();
            output.push_str(&draw_text(
                x,
                y,
                color,
                font_resource(FontRole::Label),
                align,
                &format!("dateYearValue{index}"),
                spacing,
                indent,
            ));
        }
        Representation::Calendar => {
            writeln!(
                output,
                "{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);",
                color_code(color)
            )
            .unwrap();
            writeln!(
                output,
                "{indent}dc.drawRoundedRectangle({}, {}, 62, 64, 8);",
                x - 31,
                y - 32
            )
            .unwrap();
            writeln!(
                output,
                "{indent}dc.drawLine({}, {}, {}, {});",
                x - 31,
                y - 10,
                x + 31,
                y - 10
            )
            .unwrap();
            output.push_str(&draw_text(
                x,
                y - 21,
                color,
                font_resource(FontRole::Label),
                Alignment::Center,
                &format!("monthValue{index}"),
                spacing,
                indent,
            ));
            output.push_str(&draw_text(
                x,
                y + 11,
                color,
                font_resource(FontRole::Label),
                Alignment::Center,
                &format!("date{index}.day.format(\"%02d\")"),
                spacing,
                indent,
            ));
        }
        _ => output.push_str(&draw_text(
            x,
            y,
            color,
            font_resource(FontRole::Label),
            align,
            &format!("dateValue{index}"),
            spacing,
            indent,
        )),
    }
    output
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
    representation: Representation,
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
    writeln!(
        output,
        "{indent}var hourValue{index} = hour{index}.format(\"%02d\");"
    )
    .unwrap();
    write!(
        output,
        "{indent}var minuteValue{index} = clock{index}.min.format(\"%02d\")"
    )
    .unwrap();
    if show_seconds {
        write!(output, " + \":\" + clock{index}.sec.format(\"%02d\")").unwrap();
    }
    output.push_str(";\n");
    match representation {
        Representation::Stacked => {
            output.push_str(&draw_text(
                x,
                y - 52,
                color,
                font_resource(FontRole::Time),
                align,
                &format!("hourValue{index}"),
                spacing,
                indent,
            ));
            output.push_str(&draw_text(
                x,
                y + 52,
                color,
                font_resource(FontRole::Time),
                align,
                &format!("minuteValue{index}"),
                spacing,
                indent,
            ));
        }
        Representation::Split => {
            output.push_str(&draw_text(
                x - 48,
                y,
                color,
                font_resource(FontRole::Time),
                Alignment::Center,
                &format!("hourValue{index}"),
                spacing,
                indent,
            ));
            output.push_str(&draw_text(
                x + 48,
                y,
                color,
                font_resource(FontRole::Time),
                Alignment::Center,
                &format!("minuteValue{index}"),
                spacing,
                indent,
            ));
            writeln!(
                output,
                "{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);",
                color_code(color)
            )
            .unwrap();
            writeln!(output, "{indent}dc.setPenWidth(2);\n{indent}dc.drawLine({x}, {}, {x}, {});\n{indent}dc.setPenWidth(1);", y - 24, y + 24).unwrap();
        }
        Representation::Analog | Representation::AnalogDigital => {
            output.push_str(&render_analog_clock(
                index,
                x,
                y,
                color,
                show_seconds,
                indent,
            ));
            if representation == Representation::AnalogDigital {
                output.push_str(&draw_text(
                    x,
                    y + 66,
                    color,
                    font_resource(FontRole::Label),
                    Alignment::Center,
                    &format!("timeValue{index}"),
                    0,
                    indent,
                ));
            }
        }
        Representation::SecondsRing => {
            writeln!(
                output,
                "{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);",
                color_code(color)
            )
            .unwrap();
            writeln!(output, "{indent}dc.setPenWidth(3);\n{indent}dc.drawCircle({x}, {y}, 68);\n{indent}dc.drawArc({x}, {y}, 68, Graphics.ARC_CLOCKWISE, -90, -90 + (clock{index}.sec * 6));\n{indent}dc.setPenWidth(1);").unwrap();
            output.push_str(&draw_text(
                x,
                y,
                color,
                font_resource(FontRole::Time),
                Alignment::Center,
                &format!("timeValue{index}"),
                spacing,
                indent,
            ));
        }
        _ => output.push_str(&draw_text(
            x,
            y,
            color,
            font_resource(FontRole::Time),
            align,
            &format!("timeValue{index}"),
            spacing,
            indent,
        )),
    }
    output
}

fn render_analog_clock(
    index: usize,
    x: i32,
    y: i32,
    color: &str,
    show_seconds: bool,
    indent: &str,
) -> String {
    let mut output = format!(
        "{indent}dc.setColor({}, Graphics.COLOR_TRANSPARENT);\n\
{indent}dc.setPenWidth(2);\n\
{indent}dc.drawCircle({x}, {y}, 52);\n\
{indent}for (var dialMarker{index} = 0; dialMarker{index} < 12; dialMarker{index}++) {{\n\
{indent}    var markerAngle{index} = Math.toRadians((dialMarker{index} * 30) - 90);\n\
{indent}    var markerInner{index} = (dialMarker{index} % 3 == 0) ? 39 : 43;\n\
{indent}    dc.setPenWidth((dialMarker{index} % 3 == 0) ? 2 : 1);\n\
{indent}    dc.drawLine({x} + (markerInner{index} * Math.cos(markerAngle{index})).toNumber(), {y} + (markerInner{index} * Math.sin(markerAngle{index})).toNumber(), {x} + (47 * Math.cos(markerAngle{index})).toNumber(), {y} + (47 * Math.sin(markerAngle{index})).toNumber());\n\
{indent}}}\n\
{indent}var hourAngle{index} = Math.toRadians((((clock{index}.hour % 12) * 60) + clock{index}.min) * 0.5 - 90);\n\
{indent}var minuteAngle{index} = Math.toRadians(clock{index}.min * 6 - 90);\n\
{indent}dc.setPenWidth(4);\n\
{indent}dc.drawLine({x}, {y}, {x} + (27 * Math.cos(hourAngle{index})).toNumber(), {y} + (27 * Math.sin(hourAngle{index})).toNumber());\n\
{indent}dc.setPenWidth(2);\n\
{indent}dc.drawLine({x}, {y}, {x} + (40 * Math.cos(minuteAngle{index})).toNumber(), {y} + (40 * Math.sin(minuteAngle{index})).toNumber());\n",
        color_code(color)
    );
    if show_seconds {
        writeln!(output, "{indent}var secondAngle{index} = Math.toRadians(clock{index}.sec * 6 - 90);\n{indent}dc.setPenWidth(1);\n{indent}dc.drawLine({x}, {y}, {x} + (44 * Math.cos(secondAngle{index})).toNumber(), {y} + (44 * Math.sin(secondAngle{index})).toNumber());").unwrap();
    }
    writeln!(
        output,
        "{indent}dc.fillCircle({x}, {y}, 3);\n{indent}dc.setPenWidth(1);"
    )
    .unwrap();
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
        Representation::Value,
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

fn drawables_xml(spec: &ProjectSpec) -> String {
    let mut output = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<drawables>\n\
  <bitmap id=\"LauncherIcon\" filename=\"launcher_icon.png\"/>\n"
        .to_owned();
    for (index, element) in spec.elements.iter().enumerate() {
        let icon = match element {
            Element::Icon {
                icon, style, size, ..
            } => Some((*icon, *style, *size)),
            Element::Steps {
                representation: Representation::Icon,
                ..
            } => Some((IconKind::Steps, IconStyle::Filled, 18)),
            Element::HeartRate {
                representation: Representation::Icon,
                ..
            } => Some((IconKind::Heart, IconStyle::Filled, 18)),
            Element::Stress {
                representation: Representation::Icon,
                ..
            } => Some((IconKind::Stress, IconStyle::Filled, 18)),
            Element::Battery {
                representation: Representation::Icon,
                ..
            } => Some((IconKind::Battery, IconStyle::Filled, 18)),
            Element::Calories {
                representation: Representation::Icon,
                ..
            } => Some((IconKind::Flame, IconStyle::Filled, 18)),
            Element::Distance {
                representation: Representation::Icon,
                ..
            } => Some((IconKind::Pin, IconStyle::Filled, 18)),
            _ => None,
        };
        if let Some((kind, style, size)) = icon {
            let asset = selected_icon_asset(kind, style);
            writeln!(
                output,
                "  <bitmap id=\"Icon{index}\" filename=\"{}\" scaleX=\"{size}\" scaleY=\"{size}\" scaleRelativeTo=\"screen\" dithering=\"none\" automaticPalette=\"false\"/>",
                asset.file_name,
            )
            .unwrap();
        }
    }
    output.push_str("</drawables>\n");
    output
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
