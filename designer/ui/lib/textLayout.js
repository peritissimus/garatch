import { layoutWithLines, prepareWithSegments } from "@chenglou/pretext";
import { clone } from "./project.js";
import {
  familyForRole,
  fontFamilyDetails,
  normalizeFontHeights,
  normalizeLetterSpacing,
  roleForElement,
} from "./bmfont.js";

const preparedCache = new Map();

export function typographyFor(project, element) {
  const role = roleForElement(element);
  const heights = normalizeFontHeights(project.fontHeights);
  const spacing = normalizeLetterSpacing(project.letterSpacing);
  const family = fontFamilyDetails(familyForRole(project, role));
  const fontWeight = role === "time" ? 400 : 500;
  const height = heights[role];
  const lineHeight = element.type === "label"
    ? Math.max(8, Math.min(80, Number(element.lineHeight) || Math.round(height * 1.22)))
    : height;
  return {
    role,
    height,
    lineHeight,
    letterSpacing: spacing[role],
    cssFamily: family.cssFamily,
    font: `${fontWeight} ${height}px "${family.cssFamily}"`,
    maxWidth: element.type === "label" ? Math.max(20, Math.min(320, Number(element.maxWidth) || 280)) : 4096,
  };
}

export function layoutWatchText(project, element, text) {
  const typography = typographyFor(project, element);
  const key = `${text}\u0000${typography.font}\u0000${typography.letterSpacing}`;
  let prepared = preparedCache.get(key);
  if (!prepared) {
    prepared = prepareWithSegments(text, typography.font, {
      whiteSpace: "normal",
      wordBreak: "keep-all",
      letterSpacing: typography.letterSpacing,
    });
    preparedCache.set(key, prepared);
  }
  const result = layoutWithLines(prepared, typography.maxWidth, typography.lineHeight);
  const lines = result.lines.length ? result.lines : [{ text: "", width: 0 }];
  const measuredWidth = Math.max(0, ...lines.map((line) => line.width));
  const width = Math.max(1, measuredWidth);
  const height = Math.max(typography.lineHeight, lines.length * typography.lineHeight);
  return {
    ...typography,
    width,
    height,
    measuredWidth,
    lines,
  };
}

export function positionedWatchText(project, element, text) {
  const layout = layoutWatchText(project, element, text);
  const x = element.align === "left"
    ? element.x
    : element.align === "right"
      ? element.x - layout.width
      : element.x - layout.width / 2;
  const y = element.y - layout.height / 2;
  return {
    ...layout,
    x,
    y,
    lines: layout.lines.map((line, index) => ({
      ...line,
      centerY: y + layout.lineHeight / 2 + index * layout.lineHeight,
    })),
  };
}

export async function ensureProjectFonts(project) {
  if (!document.fonts) return;
  const timeFamily = fontFamilyDetails(familyForRole(project, "time"));
  const dataFamily = fontFamilyDetails(familyForRole(project, "value"));
  const heights = normalizeFontHeights(project.fontHeights);
  await Promise.all([
    document.fonts.load(`400 ${heights.time}px "${timeFamily.cssFamily}"`),
    document.fonts.load(`500 ${heights.value}px "${dataFamily.cssFamily}"`),
    document.fonts.load(`500 ${heights.label}px "${dataFamily.cssFamily}"`),
  ]);
}

export async function prepareProjectForExport(project) {
  await ensureProjectFonts(project);
  const prepared = clone(project);
  for (const element of prepared.elements) {
    if (element.type !== "label") continue;
    element.renderedLines = layoutWatchText(prepared, element, element.text).lines.map((line) => line.text);
  }
  return prepared;
}
