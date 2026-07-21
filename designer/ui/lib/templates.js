import { DEFAULT_FONT_HEIGHTS, DEFAULT_LETTER_SPACING } from "./bmfont.js";

const face = (id, name, description, accent, fontFamily, elements, overrides = {}) => ({
  id, name, description, accent, fontFamily, elements, ...overrides,
});

export const WATCH_TEMPLATES = [
  face("night-signal", "Night Signal", "Large clock with a calm activity row.", "#72D6B2", "barlow-condensed", [
    { type: "rectangle", x: 46, y: 278, width: 228, height: 1, fillColor: "#27312D", cornerRadius: 0 },
    { type: "label", x: 160, y: 70, text: "TUE 21 JUL", color: "#72D6B2", align: "center", maxWidth: 280, lineHeight: 22 },
    { type: "time", x: 160, y: 136, color: "#FFFFFF", align: "center", format: "device", showSeconds: false },
    { type: "date", x: 160, y: 188, color: "#8D949D", align: "center" },
    { type: "steps", x: 76, y: 310, color: "#FFFFFF", align: "center" },
    { type: "heart-rate", x: 160, y: 310, color: "#EF7E74", align: "center" },
    { type: "battery", x: 244, y: 310, color: "#FFFFFF", align: "center" },
  ]),
  face("metric-grid", "Metric Grid", "A structured dashboard for daily stats.", "#8CC8FF", "rajdhani", [
    { type: "label", x: 24, y: 42, text: "DAILY STATUS", color: "#8CC8FF", align: "left", maxWidth: 270, lineHeight: 20 },
    { type: "time", x: 24, y: 112, color: "#FFFFFF", align: "left", format: "hour24", showSeconds: false },
    { type: "line", x: 24, y: 174, endX: 296, endY: 174, color: "#26323D", thickness: 1 },
    { type: "icon", x: 42, y: 218, icon: "steps", size: 24, color: "#8CC8FF" },
    { type: "steps", x: 67, y: 218, color: "#FFFFFF", align: "left" },
    { type: "icon", x: 180, y: 218, icon: "heart", size: 24, color: "#F1847C" },
    { type: "heart-rate", x: 205, y: 218, color: "#FFFFFF", align: "left" },
    { type: "icon", x: 42, y: 278, icon: "flame", size: 24, color: "#F5B45E" },
    { type: "calories", x: 67, y: 278, color: "#FFFFFF", align: "left" },
    { type: "icon", x: 180, y: 278, icon: "battery", size: 24, color: "#91D6B8" },
    { type: "battery", x: 205, y: 278, color: "#FFFFFF", align: "left" },
  ], { fontHeights: { time: 88, value: 30, label: 18 } }),
  face("minimal-halo", "Minimal Halo", "A soft geometric frame with only essentials.", "#D9B7FF", "space-grotesk", [
    { type: "ellipse", x: 160, y: 176, radiusX: 118, radiusY: 118, fillColor: "#17131E" },
    { type: "icon", x: 160, y: 76, icon: "sun", size: 24, color: "#D9B7FF" },
    { type: "time", x: 160, y: 158, color: "#FFFFFF", align: "center", format: "device", showSeconds: false },
    { type: "date", x: 160, y: 216, color: "#B9ACCA", align: "center" },
    { type: "battery", x: 160, y: 322, color: "#D9B7FF", align: "center" },
  ], { fontHeights: { time: 88, value: 30, label: 18 } }),
  face("sport-split", "Sport Split", "Bold time paired with training metrics.", "#F5B45E", "oxanium", [
    { type: "rectangle", x: 0, y: 0, width: 12, height: 360, fillColor: "#F5B45E", cornerRadius: 0 },
    { type: "label", x: 34, y: 46, text: "MOVE / RECOVER", color: "#F5B45E", align: "left", maxWidth: 250, lineHeight: 20 },
    { type: "time", x: 34, y: 122, color: "#FFFFFF", align: "left", format: "hour24", showSeconds: false },
    { type: "steps", x: 34, y: 232, color: "#FFFFFF", align: "left" },
    { type: "label", x: 34, y: 260, text: "STEPS", color: "#6F7780", align: "left", maxWidth: 80, lineHeight: 18 },
    { type: "heart-rate", x: 202, y: 232, color: "#F1847C", align: "left" },
    { type: "label", x: 202, y: 260, text: "HEART", color: "#6F7780", align: "left", maxWidth: 80, lineHeight: 18 },
    { type: "distance", x: 34, y: 320, color: "#8CC8FF", align: "left", unit: "kilometers" },
  ], { fontHeights: { time: 88, value: 36, label: 18 } }),
  face("linear", "Linear", "Fine rules and compact information density.", "#B8E986", "archivo-narrow", [
    { type: "date", x: 24, y: 42, color: "#B8E986", align: "left" },
    { type: "battery", x: 296, y: 42, color: "#FFFFFF", align: "right" },
    { type: "time", x: 160, y: 144, color: "#FFFFFF", align: "center", format: "device", showSeconds: false },
    { type: "line", x: 24, y: 204, endX: 296, endY: 204, color: "#B8E986", thickness: 2 },
    { type: "label", x: 24, y: 248, text: "STEPS", color: "#717A72", align: "left", maxWidth: 80, lineHeight: 18 },
    { type: "steps", x: 24, y: 280, color: "#FFFFFF", align: "left" },
    { type: "label", x: 296, y: 248, text: "DISTANCE", color: "#717A72", align: "right", maxWidth: 100, lineHeight: 18 },
    { type: "distance", x: 296, y: 280, color: "#FFFFFF", align: "right", unit: "kilometers" },
  ], { fontHeights: { time: 104, value: 30, label: 18 } }),
  face("big-time", "Big Time", "Maximum legibility with one glance metrics.", "#FF6B5E", "oswald", [
    { type: "time", x: 160, y: 148, color: "#FFFFFF", align: "center", format: "device", showSeconds: false },
    { type: "rectangle", x: 50, y: 210, width: 220, height: 44, fillColor: "#FF6B5E", cornerRadius: 22 },
    { type: "date", x: 160, y: 232, color: "#120503", align: "center" },
    { type: "icon", x: 95, y: 302, icon: "heart", size: 22, color: "#FF6B5E" },
    { type: "heart-rate", x: 118, y: 302, color: "#FFFFFF", align: "left" },
    { type: "icon", x: 205, y: 302, icon: "battery", size: 22, color: "#BFC7D0" },
    { type: "battery", x: 228, y: 302, color: "#FFFFFF", align: "left" },
  ], { fontHeights: { time: 104, value: 30, label: 18 } }),
];

export function createProjectFromTemplate(templateId = "night-signal") {
  const template = WATCH_TEMPLATES.find((item) => item.id === templateId) ?? WATCH_TEMPLATES[0];
  return {
    name: template.name,
    appId: crypto.randomUUID().replaceAll("-", ""),
    backgroundColor: template.backgroundColor ?? "#000000",
    fontFamily: template.fontFamily,
    fontHeights: { ...DEFAULT_FONT_HEIGHTS, ...template.fontHeights },
    letterSpacing: { ...DEFAULT_LETTER_SPACING, ...template.letterSpacing },
    elements: template.elements.map((element) => ({
      ...structuredClone(element),
      id: `${element.type}-${crypto.randomUUID().replaceAll("-", "").slice(0, 8)}`,
    })),
  };
}
