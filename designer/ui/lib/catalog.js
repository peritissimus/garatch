export const ELEMENT_CATALOG = [
  { type: "time", glyph: "12:34", name: "Time", description: "Digital clock", tone: "mint" },
  { type: "date", glyph: "21", name: "Date", description: "Day + month", tone: "blue" },
  { type: "steps", glyph: "8K", name: "Steps", description: "Daily activity", tone: "amber" },
  { type: "heart-rate", glyph: "♥", name: "Heart rate", description: "Current BPM", tone: "coral" },
  { type: "battery", glyph: "83", name: "Battery", description: "Device charge", tone: "violet" },
  { type: "label", glyph: "Aa", name: "Label", description: "Static text", tone: "neutral" },
  { type: "rectangle", glyph: "▭", name: "Shape", description: "Block + divider", tone: "neutral" },
];

export const TYPE_NAMES = Object.fromEntries(ELEMENT_CATALOG.map(({ type, name }) => [type, name]));

export const TYPE_GLYPHS = {
  time: "12",
  date: "D",
  steps: "ST",
  "heart-rate": "HR",
  battery: "%",
  label: "Aa",
  rectangle: "▭",
};

export const ALIGN_OPTIONS = [
  ["left", "Left"],
  ["center", "Center"],
  ["right", "Right"],
];
