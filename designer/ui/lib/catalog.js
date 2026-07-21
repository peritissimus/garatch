export const ELEMENT_CATALOG = [
  { type: "time", glyph: "12:34", name: "Time", description: "Digital clock", tone: "mint" },
  { type: "date", glyph: "21", name: "Date", description: "Day + month", tone: "blue" },
  { type: "steps", glyph: "8K", name: "Steps", description: "Daily activity", tone: "amber" },
  { type: "heart-rate", glyph: "♥", name: "Heart rate", description: "Current BPM", tone: "coral" },
  { type: "battery", glyph: "83", name: "Battery", description: "Device charge", tone: "violet" },
  { type: "calories", glyph: "356", name: "Calories", description: "Daily burn", tone: "amber" },
  { type: "distance", glyph: "4.2", name: "Distance", description: "Km or miles", tone: "blue" },
  { type: "label", glyph: "Aa", name: "Label", description: "Static text", tone: "neutral" },
  { type: "rectangle", glyph: "▭", name: "Rectangle", description: "Block + divider", tone: "neutral" },
  { type: "ellipse", glyph: "○", name: "Ellipse", description: "Circle + oval", tone: "neutral" },
  { type: "line", glyph: "╱", name: "Line", description: "Rules + accents", tone: "neutral" },
];

export const TYPE_NAMES = Object.fromEntries(ELEMENT_CATALOG.map(({ type, name }) => [type, name]));

export const TYPE_GLYPHS = {
  time: "12",
  date: "D",
  steps: "ST",
  "heart-rate": "HR",
  battery: "%",
  calories: "CAL",
  distance: "KM",
  label: "Aa",
  rectangle: "▭",
  ellipse: "○",
  line: "╱",
};

export const ALIGN_OPTIONS = [
  ["left", "Left"],
  ["center", "Center"],
  ["right", "Right"],
];
