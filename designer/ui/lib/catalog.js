export const ELEMENT_CATALOG = [
  { type: "time", glyph: "12:34", name: "Time", description: "Live clock", tone: "mint", group: "dynamic" },
  { type: "date", glyph: "21", name: "Date", description: "Today’s date", tone: "blue", group: "dynamic" },
  { type: "steps", glyph: "8K", name: "Steps", description: "Daily activity", tone: "amber", group: "dynamic" },
  { type: "heart-rate", glyph: "♥", name: "Heart rate", description: "Current BPM", tone: "coral", group: "dynamic" },
  { type: "stress", glyph: "≈", name: "Stress", description: "Current stress", tone: "violet", group: "dynamic" },
  { type: "battery", glyph: "83", name: "Battery", description: "Device charge", tone: "violet", group: "dynamic" },
  { type: "calories", glyph: "356", name: "Calories", description: "Daily burn", tone: "amber", group: "dynamic" },
  { type: "distance", glyph: "4.2", name: "Distance", description: "Km or miles", tone: "blue", group: "dynamic" },
  { type: "label", glyph: "Aa", name: "Label", description: "Fixed text", tone: "neutral", group: "static" },
  { type: "rectangle", glyph: "▭", name: "Rectangle", description: "Block + divider", tone: "neutral", group: "static" },
  { type: "ellipse", glyph: "○", name: "Ellipse", description: "Circle + oval", tone: "neutral", group: "static" },
  { type: "line", glyph: "╱", name: "Line", description: "Rules + accents", tone: "neutral", group: "static" },
  { type: "icon", glyph: "♥", name: "Icon", description: "Fixed symbol", tone: "coral", group: "static" },
];

export const DYNAMIC_CATALOG = ELEMENT_CATALOG.filter((item) => item.group === "dynamic");
export const STATIC_CATALOG = ELEMENT_CATALOG.filter((item) => item.group === "static");
export const DYNAMIC_TYPES = new Set(DYNAMIC_CATALOG.map((item) => item.type));

export const REPRESENTATION_OPTIONS = {
  time: [
    { id: "value", name: "Digital", description: "One-line clock", preview: "10:28" },
    { id: "stacked", name: "Stacked", description: "Hours over minutes", preview: "10\n28" },
    { id: "split", name: "Split", description: "Hours and minutes as blocks", preview: "10  28" },
    { id: "analog", name: "Analog", description: "Hands and hour ring", preview: "◷" },
    { id: "analog-digital", name: "Hybrid", description: "Analog hands with digital time", preview: "◷ 10:28" },
    { id: "seconds-ring", name: "Seconds ring", description: "Digital time with a live arc", preview: "◔ 10:28" },
  ],
  date: [
    { id: "value", name: "Numeric", description: "Day and month", preview: "22/07" },
    { id: "stacked", name: "Stacked", description: "Day over month", preview: "22\n07" },
    { id: "weekday", name: "Weekday", description: "Day name only", preview: "WED" },
    { id: "month-day", name: "Month + day", description: "Short month and date", preview: "JUL 22" },
    { id: "full-date", name: "Full date", description: "Weekday, month, and date", preview: "WED, JUL 22" },
    { id: "date-year", name: "Date + year", description: "Date, month, and year", preview: "22 JUL 2026" },
    { id: "calendar", name: "Calendar", description: "Compact calendar tile", preview: "JUL\n22" },
  ],
  steps: goalRepresentations("8.4K", "ST", "Daily goal"),
  "heart-rate": historyRepresentations("72", "♥", "Five zones · 50–100% max"),
  stress: historyRepresentations("38", "≈", "Five levels · 0–100"),
  battery: goalRepresentations("83%", "▰", "Charge level"),
  calories: goalRepresentations("356", "◆", "Daily goal"),
  distance: goalRepresentations("4.2", "⌖", "Distance goal"),
};

function baseRepresentations(value, icon) {
  return [
    { id: "value", name: "Value", description: "Number only", preview: value },
    { id: "icon-value", name: "Icon + value", description: "Symbol and number", preview: `${icon} ${value}` },
  ];
}

function goalRepresentations(value, icon, ringDescription) {
  return [
    ...baseRepresentations(value, icon),
    { id: "progress-bar", name: "Goal bar", description: "Progress toward a target", preview: value },
    { id: "goal-ring", name: "Goal ring", description: ringDescription, preview: value },
  ];
}

function historyRepresentations(value, icon, gaugeDescription) {
  return [
    ...baseRepresentations(value, icon),
    { id: "zone-gauge", name: "Zone gauge", description: gaugeDescription, preview: value },
    { id: "history-graph", name: "History graph", description: "Recent sensor samples", preview: value },
  ];
}

export const TYPE_NAMES = Object.fromEntries(ELEMENT_CATALOG.map(({ type, name }) => [type, name]));

export const TYPE_GLYPHS = {
  time: "12",
  date: "D",
  steps: "ST",
  "heart-rate": "HR",
  stress: "STR",
  battery: "%",
  calories: "CAL",
  distance: "KM",
  label: "Aa",
  rectangle: "▭",
  ellipse: "○",
  line: "╱",
  icon: "♥",
};

export const ALIGN_OPTIONS = [
  ["left", "Left"],
  ["center", "Center"],
  ["right", "Right"],
];
