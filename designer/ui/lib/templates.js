import { DEFAULT_FONT_HEIGHTS, DEFAULT_LETTER_SPACING } from "./bmfont.js";

const face = (id, name, description, category, accent, fontFamily, elements, overrides = {}) => ({
  id, name, description, category, accent, fontFamily, elements, ...overrides,
});

export const WATCH_TEMPLATES = [
  face("night-signal", "Night Signal", "A calm clock with an activity pulse along the edge.", "Digital", "#72D6B2", "barlow-condensed", [
    { type: "rectangle", x: 24, y: 42, width: 4, height: 236, fillColor: "#72D6B2", cornerRadius: 2 },
    { type: "label", x: 44, y: 56, text: "NIGHT SIGNAL", color: "#72D6B2", align: "left", maxWidth: 240, lineHeight: 20 },
    { type: "time", x: 44, y: 129, color: "#FFFFFF", align: "left", format: "device", showSeconds: false, representation: "value" },
    { type: "date", x: 44, y: 188, color: "#8D949D", align: "left", representation: "full-date" },
    { type: "line", x: 44, y: 270, endX: 294, endY: 270, color: "#27312D", thickness: 1 },
    { type: "steps", x: 44, y: 310, color: "#FFFFFF", align: "left", representation: "icon-value" },
    { type: "heart-rate", x: 160, y: 310, color: "#EF7E74", align: "center", representation: "icon-value" },
    { type: "battery", x: 294, y: 310, color: "#FFFFFF", align: "right", representation: "icon-value" },
  ]),
  face("orbit-analog", "Orbit", "A pure analog dial with quiet complications.", "Analog", "#F4D06F", "space-grotesk", [
    { type: "ellipse", x: 160, y: 166, radiusX: 93, radiusY: 93, fillColor: "#15140F" },
    { type: "date", x: 160, y: 37, color: "#F4D06F", align: "center", representation: "weekday" },
    { type: "time", x: 160, y: 166, color: "#F4D06F", align: "center", format: "device", showSeconds: true, representation: "analog" },
    { type: "line", x: 76, y: 276, endX: 244, endY: 276, color: "#343126", thickness: 1 },
    { type: "steps", x: 92, y: 310, color: "#FFFFFF", align: "center", representation: "icon-value" },
    { type: "battery", x: 228, y: 310, color: "#FFFFFF", align: "center", representation: "icon-value" },
  ], { backgroundColor: "#050504", fontHeights: { time: 72, value: 24, label: 18 } }),
  face("instrument-hybrid", "Instrument", "Analog motion paired with a crisp digital readout.", "Analog", "#82C8FF", "oxanium", [
    { type: "rectangle", x: 18, y: 18, width: 284, height: 324, fillColor: "#09131B", cornerRadius: 28 },
    { type: "label", x: 160, y: 45, text: "FIELD / 07", color: "#82C8FF", align: "center", maxWidth: 220, lineHeight: 18 },
    { type: "time", x: 160, y: 142, color: "#FFFFFF", align: "center", format: "hour24", showSeconds: false, representation: "analog-digital" },
    { type: "date", x: 160, y: 240, color: "#82C8FF", align: "center", representation: "month-day" },
    { type: "steps", x: 82, y: 300, color: "#C6E7FF", align: "center", representation: "goal-ring", progressMax: 10000 },
    { type: "battery", x: 238, y: 300, color: "#82C8FF", align: "center", representation: "goal-ring" },
  ], { backgroundColor: "#03080C", fontHeights: { time: 72, value: 24, label: 14 } }),
  face("seconds-halo", "Seconds Halo", "A live seconds arc built for precise glances.", "Digital", "#FF715B", "rajdhani", [
    { type: "label", x: 160, y: 42, text: "MAKE EVERY SECOND", color: "#70615E", align: "center", maxWidth: 260, lineHeight: 18 },
    { type: "time", x: 160, y: 154, color: "#FF715B", align: "center", format: "hour24", showSeconds: false, representation: "seconds-ring" },
    { type: "date", x: 160, y: 246, color: "#FFFFFF", align: "center", representation: "full-date" },
    { type: "heart-rate", x: 88, y: 305, color: "#FF715B", align: "center", representation: "icon-value" },
    { type: "stress", x: 232, y: 305, color: "#B794F6", align: "center", representation: "icon-value" },
  ], { backgroundColor: "#0D0807", fontHeights: { time: 72, value: 24, label: 14 } }),
  face("metric-grid", "Metric Grid", "A structured dashboard for daily stats.", "Data", "#8CC8FF", "rajdhani", [
    { type: "label", x: 24, y: 42, text: "DAILY STATUS", color: "#8CC8FF", align: "left", maxWidth: 270, lineHeight: 20 },
    { type: "time", x: 24, y: 112, color: "#FFFFFF", align: "left", format: "hour24", showSeconds: false, representation: "value" },
    { type: "line", x: 24, y: 174, endX: 296, endY: 174, color: "#26323D", thickness: 1 },
    { type: "steps", x: 28, y: 220, color: "#8CC8FF", align: "left", representation: "icon-value" },
    { type: "heart-rate", x: 172, y: 220, color: "#F1847C", align: "left", representation: "icon-value" },
    { type: "calories", x: 28, y: 282, color: "#F5B45E", align: "left", representation: "icon-value" },
    { type: "battery", x: 172, y: 282, color: "#91D6B8", align: "left", representation: "icon-value" },
  ], { fontHeights: { time: 88, value: 30, label: 18 } }),
  face("pulse-trace", "Pulse Trace", "Live heart and stress history in a training layout.", "Wellness", "#FF7A70", "archivo-narrow", [
    { type: "rectangle", x: 0, y: 0, width: 320, height: 72, fillColor: "#1B0C0D", cornerRadius: 0 },
    { type: "time", x: 22, y: 38, color: "#FFFFFF", align: "left", format: "hour24", showSeconds: false, representation: "value" },
    { type: "date", x: 295, y: 38, color: "#FF7A70", align: "right", representation: "weekday" },
    { type: "label", x: 24, y: 112, text: "HEART RATE", color: "#7F696A", align: "left", maxWidth: 150, lineHeight: 18 },
    { type: "heart-rate", x: 24, y: 150, color: "#FF7A70", align: "left", representation: "history-graph" },
    { type: "label", x: 24, y: 230, text: "STRESS", color: "#71677D", align: "left", maxWidth: 150, lineHeight: 18 },
    { type: "stress", x: 24, y: 266, color: "#B794F6", align: "left", representation: "history-graph" },
    { type: "battery", x: 296, y: 326, color: "#8A9299", align: "right", representation: "icon-value" },
  ], { backgroundColor: "#080506", fontHeights: { time: 72, value: 24, label: 14 } }),
  face("goal-orbits", "Goal Orbits", "Color-coded rings for movement, energy, and range.", "Data", "#72D6B2", "space-grotesk", [
    { type: "date", x: 160, y: 40, color: "#78807C", align: "center", representation: "full-date" },
    { type: "time", x: 160, y: 104, color: "#FFFFFF", align: "center", format: "device", showSeconds: false, representation: "value" },
    { type: "steps", x: 64, y: 210, color: "#72D6B2", align: "center", representation: "goal-ring", progressMax: 10000 },
    { type: "calories", x: 160, y: 210, color: "#F5B45E", align: "center", representation: "goal-ring", progressMax: 500 },
    { type: "distance", x: 256, y: 210, color: "#8CC8FF", align: "center", representation: "goal-ring", progressMax: 5, unit: "kilometers" },
    { type: "label", x: 64, y: 268, text: "STEPS", color: "#58605C", align: "center", maxWidth: 72, lineHeight: 16 },
    { type: "label", x: 160, y: 268, text: "CAL", color: "#665D4E", align: "center", maxWidth: 72, lineHeight: 16 },
    { type: "label", x: 256, y: 268, text: "KM", color: "#536373", align: "center", maxWidth: 72, lineHeight: 16 },
    { type: "battery", x: 160, y: 326, color: "#FFFFFF", align: "center", representation: "progress-bar" },
  ], { fontHeights: { time: 72, value: 24, label: 14 } }),
  face("minimal-halo", "Minimal Halo", "A soft geometric frame with only essentials.", "Minimal", "#D9B7FF", "space-grotesk", [
    { type: "ellipse", x: 160, y: 176, radiusX: 118, radiusY: 118, fillColor: "#17131E" },
    { type: "icon", x: 160, y: 76, icon: "sun", style: "regular", size: 24, color: "#D9B7FF" },
    { type: "time", x: 160, y: 158, color: "#FFFFFF", align: "center", format: "device", showSeconds: false, representation: "value" },
    { type: "date", x: 160, y: 216, color: "#B9ACCA", align: "center", representation: "month-day" },
    { type: "battery", x: 160, y: 322, color: "#D9B7FF", align: "center", representation: "icon-value" },
  ], { fontHeights: { time: 88, value: 30, label: 18 } }),
  face("sport-split", "Sport Split", "Bold split time paired with training metrics.", "Digital", "#F5B45E", "oxanium", [
    { type: "rectangle", x: 0, y: 0, width: 12, height: 360, fillColor: "#F5B45E", cornerRadius: 0 },
    { type: "label", x: 34, y: 42, text: "MOVE / RECOVER", color: "#F5B45E", align: "left", maxWidth: 250, lineHeight: 20 },
    { type: "time", x: 160, y: 116, color: "#FFFFFF", align: "center", format: "hour24", showSeconds: false, representation: "split" },
    { type: "steps", x: 34, y: 224, color: "#FFFFFF", align: "left", representation: "progress-bar", progressMax: 10000 },
    { type: "heart-rate", x: 202, y: 224, color: "#F1847C", align: "left", representation: "zone-gauge", progressMax: 200 },
    { type: "distance", x: 34, y: 310, color: "#8CC8FF", align: "left", unit: "kilometers", representation: "icon-value" },
  ], { fontHeights: { time: 72, value: 30, label: 14 } }),
  face("linear", "Linear", "Fine rules and compact information density.", "Minimal", "#B8E986", "archivo-narrow", [
    { type: "date", x: 24, y: 42, color: "#B8E986", align: "left", representation: "month-day" },
    { type: "battery", x: 296, y: 42, color: "#FFFFFF", align: "right", representation: "icon-value" },
    { type: "time", x: 160, y: 144, color: "#FFFFFF", align: "center", format: "device", showSeconds: false, representation: "value" },
    { type: "line", x: 24, y: 204, endX: 296, endY: 204, color: "#B8E986", thickness: 2 },
    { type: "label", x: 24, y: 248, text: "STEPS", color: "#717A72", align: "left", maxWidth: 80, lineHeight: 18 },
    { type: "steps", x: 24, y: 280, color: "#FFFFFF", align: "left", representation: "value" },
    { type: "label", x: 296, y: 248, text: "DISTANCE", color: "#717A72", align: "right", maxWidth: 100, lineHeight: 18 },
    { type: "distance", x: 296, y: 280, color: "#FFFFFF", align: "right", unit: "kilometers", representation: "value" },
  ], { fontHeights: { time: 104, value: 30, label: 18 } }),
  face("recovery", "Recovery", "Wellness zones with space to breathe.", "Wellness", "#B794F6", "barlow-condensed", [
    { type: "label", x: 24, y: 38, text: "RECOVERY", color: "#B794F6", align: "left", maxWidth: 180, lineHeight: 18 },
    { type: "date", x: 296, y: 38, color: "#81788C", align: "right", representation: "weekday" },
    { type: "time", x: 24, y: 104, color: "#FFFFFF", align: "left", format: "device", showSeconds: false, representation: "value" },
    { type: "line", x: 24, y: 154, endX: 296, endY: 154, color: "#2A2430", thickness: 1 },
    { type: "label", x: 24, y: 190, text: "HEART", color: "#756D79", align: "left", maxWidth: 72, lineHeight: 16 },
    { type: "heart-rate", x: 24, y: 220, color: "#FF7A70", align: "left", representation: "zone-gauge", progressMax: 200 },
    { type: "label", x: 184, y: 190, text: "STRESS", color: "#756D79", align: "left", maxWidth: 72, lineHeight: 16 },
    { type: "stress", x: 184, y: 220, color: "#B794F6", align: "left", representation: "zone-gauge" },
    { type: "steps", x: 24, y: 310, color: "#72D6B2", align: "left", representation: "icon-value" },
    { type: "battery", x: 296, y: 310, color: "#FFFFFF", align: "right", representation: "icon-value" },
  ], { backgroundColor: "#09070B", fontHeights: { time: 72, value: 24, label: 14 } }),
  face("big-time", "Big Time", "Maximum legibility with one-glance metrics.", "Digital", "#FF6B5E", "oswald", [
    { type: "time", x: 160, y: 138, color: "#FFFFFF", align: "center", format: "device", showSeconds: false, representation: "stacked" },
    { type: "rectangle", x: 50, y: 246, width: 220, height: 44, fillColor: "#FF6B5E", cornerRadius: 22 },
    { type: "date", x: 160, y: 268, color: "#120503", align: "center", representation: "full-date" },
    { type: "heart-rate", x: 92, y: 326, color: "#FF6B5E", align: "center", representation: "icon-value" },
    { type: "battery", x: 228, y: 326, color: "#BFC7D0", align: "center", representation: "icon-value" },
  ], { fontHeights: { time: 72, value: 24, label: 14 } }),
];

export function createProjectFromTemplate(templateId = "night-signal") {
  const template = WATCH_TEMPLATES.find((item) => item.id === templateId) ?? WATCH_TEMPLATES[0];
  return {
    name: template.name,
    appId: crypto.randomUUID().replaceAll("-", ""),
    backgroundColor: template.backgroundColor ?? "#000000",
    fontFamily: template.fontFamily,
    fontFamilySecondary: template.fontFamilySecondary ?? template.fontFamily,
    fontHeights: { ...DEFAULT_FONT_HEIGHTS, ...template.fontHeights },
    letterSpacing: { ...DEFAULT_LETTER_SPACING, ...template.letterSpacing },
    elements: template.elements.map((element) => ({
      ...structuredClone(element),
      ...(element.type === "icon" ? { style: element.style ?? "filled" } : {}),
      id: `${element.type}-${crypto.randomUUID().replaceAll("-", "").slice(0, 8)}`,
    })),
  };
}
