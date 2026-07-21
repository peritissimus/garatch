import { normalizeFontFamily, normalizeFontHeights, normalizeLetterSpacing } from "./bmfont.js";
import { createProjectFromTemplate } from "./templates.js";

export const WATCH_WIDTH = 320;
export const WATCH_HEIGHT = 360;
export const STORAGE_KEY = "garatch-studio-project-v1";

export function isShapeElement(element) {
  return ["rectangle", "ellipse", "line", "icon"].includes(element?.type);
}

function createId(type) {
  return `${type}-${crypto.randomUUID().replaceAll("-", "").slice(0, 8)}`;
}

export function createSampleProject() {
  return createProjectFromTemplate();
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
  if (element.type === "ellipse") {
    return {
      x: Math.round(Math.max(element.radiusX, Math.min(WATCH_WIDTH - 1 - element.radiusX, x))),
      y: Math.round(Math.max(element.radiusY, Math.min(WATCH_HEIGHT - 1 - element.radiusY, y))),
    };
  }
  if (element.type === "line") {
    const requestedX = Math.round(x);
    const requestedY = Math.round(y);
    const minX = Math.min(element.x, element.endX);
    const maxX = Math.max(element.x, element.endX);
    const minY = Math.min(element.y, element.endY);
    const maxY = Math.max(element.y, element.endY);
    const dx = Math.max(-minX, Math.min(WATCH_WIDTH - 1 - maxX, requestedX - element.x));
    const dy = Math.max(-minY, Math.min(WATCH_HEIGHT - 1 - maxY, requestedY - element.y));
    return { x: element.x + dx, y: element.y + dy };
  }
  if (element.type === "icon") {
    const half = element.size / 2;
    return {
      x: Math.round(Math.max(half, Math.min(WATCH_WIDTH - 1 - half, x))),
      y: Math.round(Math.max(half, Math.min(WATCH_HEIGHT - 1 - half, y))),
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
  if (type === "ellipse") {
    return { ...common, type, radiusX: 54, radiusY: 36, fillColor: "#27312D" };
  }
  if (type === "line") {
    return { ...common, type, x: 60, endX: 260, endY: 180, color: "#72D6B2", thickness: 1 };
  }
  if (type === "icon") return { ...common, type, icon: "heart", size: 32, color: "#EF7E74" };
  const base = { ...common, type, color: "#FFFFFF", align: "center" };
  if (type === "time") return { ...base, y: 132, format: "device", showSeconds: false };
  if (type === "date") return { ...base, y: 210 };
  if (type === "steps") return { ...base, y: 260, color: "#72D6B2" };
  if (type === "heart-rate") return { ...base, y: 290, color: "#EF7E74" };
  if (type === "battery") return { ...base, y: 320 };
  if (type === "calories") return { ...base, y: 290, color: "#E5AD59" };
  if (type === "distance") return { ...base, y: 290, color: "#78A6D6", unit: "kilometers" };
  return { ...base, type: "label", y: 80, text: "YOUR LABEL", maxWidth: 280, lineHeight: 22 };
}

export function duplicateElement(element) {
  const copy = structuredClone(element);
  copy.id = createId(element.type);
  const position = clampPosition(copy, copy.x + 12, copy.y + 12);
  if (copy.type === "line") {
    copy.endX += position.x - copy.x;
    copy.endY += position.y - copy.y;
  }
  copy.x = position.x;
  copy.y = position.y;
  return copy;
}

export function slugify(value) {
  return value.toLowerCase().trim().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || "garatch-project";
}
