use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct ProjectSpec {
    pub name: String,
    pub app_id: String,
    #[serde(default = "default_background")]
    pub background_color: String,
    #[serde(default)]
    pub font_family: FontFamily,
    #[serde(default)]
    pub font_heights: FontHeights,
    #[serde(default)]
    pub letter_spacing: LetterSpacing,
    #[serde(default)]
    pub elements: Vec<Element>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(
    tag = "type",
    rename_all = "kebab-case",
    rename_all_fields = "camelCase"
)]
pub enum Element {
    Time {
        id: String,
        x: i32,
        y: i32,
        #[serde(default = "default_foreground")]
        color: String,
        #[serde(default = "default_time_font")]
        font: Font,
        #[serde(default)]
        align: Alignment,
        #[serde(default)]
        format: TimeFormat,
        #[serde(default)]
        show_seconds: bool,
    },
    Date {
        id: String,
        x: i32,
        y: i32,
        #[serde(default = "default_foreground")]
        color: String,
        #[serde(default)]
        font: Font,
        #[serde(default)]
        align: Alignment,
    },
    Steps {
        id: String,
        x: i32,
        y: i32,
        #[serde(default = "default_foreground")]
        color: String,
        #[serde(default)]
        font: Font,
        #[serde(default)]
        align: Alignment,
    },
    HeartRate {
        id: String,
        x: i32,
        y: i32,
        #[serde(default = "default_foreground")]
        color: String,
        #[serde(default)]
        font: Font,
        #[serde(default)]
        align: Alignment,
    },
    Battery {
        id: String,
        x: i32,
        y: i32,
        #[serde(default = "default_foreground")]
        color: String,
        #[serde(default)]
        font: Font,
        #[serde(default)]
        align: Alignment,
    },
    Calories {
        id: String,
        x: i32,
        y: i32,
        #[serde(default = "default_foreground")]
        color: String,
        #[serde(default)]
        font: Font,
        #[serde(default)]
        align: Alignment,
    },
    Distance {
        id: String,
        x: i32,
        y: i32,
        #[serde(default = "default_foreground")]
        color: String,
        #[serde(default)]
        font: Font,
        #[serde(default)]
        align: Alignment,
        #[serde(default)]
        unit: DistanceUnit,
    },
    Label {
        id: String,
        x: i32,
        y: i32,
        text: String,
        #[serde(default = "default_foreground")]
        color: String,
        #[serde(default)]
        font: Font,
        #[serde(default)]
        align: Alignment,
        #[serde(default = "default_label_width")]
        max_width: u32,
        #[serde(default = "default_label_line_height")]
        line_height: u32,
        #[serde(default)]
        rendered_lines: Vec<String>,
    },
    Rectangle {
        id: String,
        x: i32,
        y: i32,
        width: u32,
        height: u32,
        #[serde(default = "default_foreground")]
        fill_color: String,
        #[serde(default)]
        corner_radius: u32,
    },
    Ellipse {
        id: String,
        x: i32,
        y: i32,
        radius_x: u32,
        radius_y: u32,
        #[serde(default = "default_foreground")]
        fill_color: String,
    },
    Line {
        id: String,
        x: i32,
        y: i32,
        end_x: i32,
        end_y: i32,
        #[serde(default = "default_foreground")]
        color: String,
        #[serde(default = "default_line_thickness")]
        thickness: u32,
    },
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Default)]
#[serde(rename_all = "kebab-case")]
pub enum Font {
    #[default]
    BarlowCondensed,
    Rajdhani,
    Tiny,
    SystemSmall,
    SystemMedium,
    SystemLarge,
    NumberHot,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Default)]
#[serde(rename_all = "kebab-case")]
pub enum FontFamily {
    #[default]
    BarlowCondensed,
    Rajdhani,
    RobotoCondensed,
    IbmPlexSansCondensed,
    Oswald,
    SairaCondensed,
    ChakraPetch,
    Oxanium,
    SpaceGrotesk,
    ArchivoNarrow,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct FontHeights {
    pub time: u32,
    pub value: u32,
    pub label: u32,
}

impl Default for FontHeights {
    fn default() -> Self {
        Self {
            time: 104,
            value: 36,
            label: 18,
        }
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Default)]
#[serde(rename_all = "camelCase")]
pub struct LetterSpacing {
    pub time: i32,
    pub value: i32,
    pub label: i32,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Default)]
#[serde(rename_all = "kebab-case")]
pub enum Alignment {
    Left,
    #[default]
    Center,
    Right,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Default)]
#[serde(rename_all = "kebab-case")]
pub enum TimeFormat {
    #[default]
    Device,
    Hour12,
    Hour24,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Default)]
#[serde(rename_all = "kebab-case")]
pub enum DistanceUnit {
    #[default]
    Kilometers,
    Miles,
}

impl Element {
    pub fn id(&self) -> &str {
        match self {
            Self::Time { id, .. }
            | Self::Date { id, .. }
            | Self::Steps { id, .. }
            | Self::HeartRate { id, .. }
            | Self::Battery { id, .. }
            | Self::Calories { id, .. }
            | Self::Distance { id, .. }
            | Self::Label { id, .. }
            | Self::Rectangle { id, .. }
            | Self::Ellipse { id, .. }
            | Self::Line { id, .. } => id,
        }
    }

    pub fn origin(&self) -> (i32, i32) {
        match self {
            Self::Time { x, y, .. }
            | Self::Date { x, y, .. }
            | Self::Steps { x, y, .. }
            | Self::HeartRate { x, y, .. }
            | Self::Battery { x, y, .. }
            | Self::Calories { x, y, .. }
            | Self::Distance { x, y, .. }
            | Self::Label { x, y, .. }
            | Self::Rectangle { x, y, .. }
            | Self::Ellipse { x, y, .. }
            | Self::Line { x, y, .. } => (*x, *y),
        }
    }

    pub fn color(&self) -> &str {
        match self {
            Self::Time { color, .. }
            | Self::Date { color, .. }
            | Self::Steps { color, .. }
            | Self::HeartRate { color, .. }
            | Self::Battery { color, .. }
            | Self::Calories { color, .. }
            | Self::Distance { color, .. }
            | Self::Label { color, .. }
            | Self::Line { color, .. } => color,
            Self::Rectangle { fill_color, .. } | Self::Ellipse { fill_color, .. } => fill_color,
        }
    }
}

pub fn default_background() -> String {
    "#000000".to_owned()
}

pub fn default_foreground() -> String {
    "#FFFFFF".to_owned()
}

fn default_time_font() -> Font {
    Font::BarlowCondensed
}

fn default_label_width() -> u32 {
    280
}

fn default_label_line_height() -> u32 {
    22
}

fn default_line_thickness() -> u32 {
    1
}
