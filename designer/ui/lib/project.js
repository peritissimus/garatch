import {
  DEFAULT_FONT_FAMILY,
  DEFAULT_FONT_HEIGHTS,
  DEFAULT_LETTER_SPACING,
  normalizeFontFamily,
  normalizeFontHeights,
  normalizeLetterSpacing,
} from "./bmfont.js";

export const WATCH_WIDTH = 320;
export const WATCH_HEIGHT = 360;
export const STORAGE_KEY = "garatch-studio-project-v1";

function createId(type) {
  return `${type}-${crypto.randomUUID().replaceAll("-", "").slice(0, 8)}`;
}

function createAppId() {
  return crypto.randomUUID().replaceAll("-", "");
}

export function createSampleProject() {
  return {
    name: "Night Signal",
    appId: createAppId(),
    backgroundColor: "#000000",
    fontFamily: DEFAULT_FONT_FAMILY,
    fontHeights: { ...DEFAULT_FONT_HEIGHTS },
    letterSpacing: { ...DEFAULT_LETTER_SPACING },
    elements: [
      { type: "rectangle", id: createId("accent"), x: 46, y: 278, width: 228, height: 1, fillColor: "#27312D", cornerRadius: 0 },
      { type: "label", id: createId("label"), x: 160, y: 70, text: "TUE 21 JUL", color: "#72D6B2", align: "center", maxWidth: 280, lineHeight: 22 },
      { type: "time", id: createId("time"), x: 160, y: 136, color: "#FFFFFF", align: "center", format: "device", showSeconds: false },
      { type: "date", id: createId("date"), x: 160, y: 188, color: "#8D949D", align: "center" },
      { type: "steps", id: createId("steps"), x: 76, y: 310, color: "#FFFFFF", align: "center" },
      { type: "heart-rate", id: createId("heart"), x: 160, y: 310, color: "#EF7E74", align: "center" },
      { type: "battery", id: createId("battery"), x: 244, y: 310, color: "#FFFFFF", align: "center" },
    ],
  };
}

export function loadProject() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return createSampleProject();
    const project = JSON.parse(raw);
    return project && Array.isArray(project.elements) ? migrateFontFamily(project) : createSampleProject();
  } catch {
    return createSampleProject();
  }
}

export function saveProject(project) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(project));
}

function migrateFontFamily(project) {
  const legacyFamily = project.elements.find((element) => element.type === "time")?.font;
  project.fontFamily = normalizeFontFamily(project.fontFamily ?? legacyFamily);
  project.fontHeights = normalizeFontHeights(project.fontHeights);
  project.letterSpacing = normalizeLetterSpacing(project.letterSpacing);
  for (const element of project.elements) {
    delete element.font;
    if (element.type === "label") {
      element.maxWidth = Math.max(20, Math.min(320, Number(element.maxWidth) || 280));
      element.lineHeight = Math.max(8, Math.min(80, Number(element.lineHeight) || 22));
      delete element.renderedLines;
    }
  }
  return project;
}

export function clampPosition(element, x, y) {
  if (element.type === "rectangle") {
    return {
      x: Math.round(Math.max(0, Math.min(WATCH_WIDTH - element.width, x))),
      y: Math.round(Math.max(0, Math.min(WATCH_HEIGHT - element.height, y))),
    };
  }
  return {
    x: Math.round(Math.max(0, Math.min(WATCH_WIDTH - 1, x))),
    y: Math.round(Math.max(0, Math.min(WATCH_HEIGHT - 1, y))),
  };
}

export function elementFactory(type) {
  const common = { id: createId(type), x: 160, y: 180 };
  if (type === "rectangle") {
    return { ...common, type, x: 90, y: 170, width: 140, height: 20, fillColor: "#72D6B2", cornerRadius: 8 };
  }
  const base = { ...common, type, color: "#FFFFFF", align: "center" };
  if (type === "time") return { ...base, y: 132, format: "device", showSeconds: false };
  if (type === "date") return { ...base, y: 210 };
  if (type === "steps") return { ...base, y: 260, color: "#72D6B2" };
  if (type === "heart-rate") return { ...base, y: 290, color: "#EF7E74" };
  if (type === "battery") return { ...base, y: 320 };
  return { ...base, type: "label", y: 80, text: "YOUR LABEL", maxWidth: 280, lineHeight: 22 };
}

export function duplicateElement(element) {
  const copy = structuredClone(element);
  copy.id = createId(element.type);
  const position = clampPosition(copy, copy.x + 12, copy.y + 12);
  copy.x = position.x;
  copy.y = position.y;
  return copy;
}

export function slugify(value) {
  return value.toLowerCase().trim().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || "garatch-project";
}
