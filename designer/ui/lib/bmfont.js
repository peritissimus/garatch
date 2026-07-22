const FONT_URLS = import.meta.glob("../assets/fonts/*_[0-9]*.{fnt,png}", {
  eager: true,
  query: "?url",
  import: "default",
});

const FONT_FILES = {
  "barlow-condensed": "garatch",
  rajdhani: "rajdhani",
  "roboto-condensed": "roboto_condensed",
  "ibm-plex-sans-condensed": "ibm_plex_sans_condensed",
  oswald: "oswald",
  "saira-condensed": "saira_condensed",
  "chakra-petch": "chakra_petch",
  oxanium: "oxanium",
  "space-grotesk": "space_grotesk",
  "archivo-narrow": "archivo_narrow",
  "dseg7-classic": "dseg7_classic",
};

export const FONT_FAMILIES = [
  { id: "barlow-condensed", name: "Barlow Condensed", tone: "Clean", cssFamily: "Garatch Barlow Condensed" },
  { id: "rajdhani", name: "Rajdhani", tone: "Tech", cssFamily: "Garatch Rajdhani" },
  { id: "roboto-condensed", name: "Roboto Condensed", tone: "Neutral", cssFamily: "Garatch Roboto Condensed" },
  { id: "ibm-plex-sans-condensed", name: "IBM Plex Sans Condensed", tone: "Human", cssFamily: "Garatch IBM Plex Sans Condensed" },
  { id: "oswald", name: "Oswald", tone: "Bold", cssFamily: "Garatch Oswald" },
  { id: "saira-condensed", name: "Saira Condensed", tone: "Sport", cssFamily: "Garatch Saira Condensed" },
  { id: "chakra-petch", name: "Chakra Petch", tone: "Square", cssFamily: "Garatch Chakra Petch" },
  { id: "oxanium", name: "Oxanium", tone: "Future", cssFamily: "Garatch Oxanium" },
  { id: "space-grotesk", name: "Space Grotesk", tone: "Modern", cssFamily: "Garatch Space Grotesk" },
  { id: "archivo-narrow", name: "Archivo Narrow", tone: "Compact", cssFamily: "Garatch Archivo Narrow" },
  { id: "dseg7-classic", name: "DSEG 7 Classic", tone: "LCD", cssFamily: "Garatch DSEG7 Classic" },
];

export const DEFAULT_FONT_FAMILY = "barlow-condensed";

export const DEFAULT_FONT_HEIGHTS = { time: 104, value: 36, label: 18 };
export const DEFAULT_LETTER_SPACING = { time: 0, value: 0, label: 0 };

export const FONT_HEIGHT_OPTIONS = {
  time: [72, 88, 104, 120],
  value: [24, 30, 36, 42],
  label: [14, 18, 22, 26],
};

export const FONT_ROLE_DETAILS = {
  time: { name: "Time" },
  value: { name: "Value" },
  label: { name: "Label" },
};

const fontCache = new Map();

export function roleForElement(element) {
  if (element.type === "time") return "time";
  if (element.type === "label" || element.type === "date") return "label";
  return "value";
}

export function normalizeFontFamily(font) {
  return FONT_FAMILIES.some((family) => family.id === font) ? font : DEFAULT_FONT_FAMILY;
}

// The time role uses the primary family; value + label use the secondary
// family, which falls back to the primary when unset.
export function familyForRole(project, role) {
  return role === "time"
    ? normalizeFontFamily(project.fontFamily)
    : normalizeFontFamily(project.fontFamilySecondary ?? project.fontFamily);
}

export function fontForElement(fonts, element) {
  return fonts[roleForElement(element)];
}

export function fontFamilyDetails(family) {
  return FONT_FAMILIES.find((item) => item.id === normalizeFontFamily(family)) ?? FONT_FAMILIES[0];
}

export function normalizeFontHeights(heights = {}) {
  return Object.fromEntries(Object.entries(FONT_HEIGHT_OPTIONS).map(([role, options]) => [
    role,
    options.includes(Number(heights[role])) ? Number(heights[role]) : DEFAULT_FONT_HEIGHTS[role],
  ]));
}

export function normalizeLetterSpacing(spacing = {}) {
  return Object.fromEntries(Object.keys(DEFAULT_LETTER_SPACING).map((role) => [
    role,
    Math.max(-2, Math.min(6, Number.isFinite(Number(spacing[role])) ? Math.round(Number(spacing[role])) : 0)),
  ]));
}

// Loads the bitmap fonts for a face: time from the primary family, value and
// label from the secondary family (both fall back to the primary when unset).
export function loadWatchFonts(primaryFamily, secondaryFamily, heights) {
  const primary = normalizeFontFamily(primaryFamily);
  const secondary = normalizeFontFamily(secondaryFamily ?? primaryFamily);
  const normalizedHeights = normalizeFontHeights(heights);
  const key = `${primary}|${secondary}:${normalizedHeights.time}:${normalizedHeights.value}:${normalizedHeights.label}`;
  if (!fontCache.has(key)) {
    const roleFamily = { time: primary, value: secondary, label: secondary };
    const promise = Promise.all(["time", "value", "label"].map(async (role) => {
      const stem = `${FONT_FILES[roleFamily[role]]}_${role}_${normalizedHeights[role]}`;
      return [role, await loadFont({
        descriptor: FONT_URLS[`../assets/fonts/${stem}.fnt`],
        atlas: FONT_URLS[`../assets/fonts/${stem}.png`],
      })];
    })).then((entries) => Object.fromEntries(entries));
    fontCache.set(key, promise);
  }
  return fontCache.get(key);
}

export function measureBitmapText(font, text, letterSpacing = 0) {
  let width = 0;
  let glyphCount = 0;
  for (const character of text) {
    const glyph = font.characters.get(character) ?? font.characters.get("?");
    if (glyph) {
      width += glyph.xadvance;
      glyphCount += 1;
    }
  }
  if (glyphCount > 1) width += letterSpacing * (glyphCount - 1);
  return { width, height: font.lineHeight };
}

export function bitmapTextBounds(font, text, x, y, align, letterSpacing = 0) {
  const { width, height } = measureBitmapText(font, text, letterSpacing);
  const left = align === "left" ? x : align === "right" ? x - width : x - Math.floor(width / 2);
  return { x: left, y: y - Math.floor(height / 2), width, height };
}

export function drawBitmapText(context, font, text, x, y, align, color, letterSpacing = 0) {
  const bounds = bitmapTextBounds(font, text, x, y, align, letterSpacing);
  const atlas = tintedAtlas(font, color);
  let cursor = bounds.x;

  context.save();
  context.imageSmoothingEnabled = false;
  for (const character of text) {
    const glyph = font.characters.get(character) ?? font.characters.get("?");
    if (!glyph) continue;
    if (glyph.width > 0 && glyph.height > 0) {
      context.drawImage(
        atlas,
        glyph.x,
        glyph.y,
        glyph.width,
        glyph.height,
        cursor + glyph.xoffset,
        bounds.y + glyph.yoffset,
        glyph.width,
        glyph.height,
      );
    }
    cursor += glyph.xadvance + letterSpacing;
  }
  context.restore();
  return bounds;
}

async function loadFont(source) {
  const [descriptor, image] = await Promise.all([
    fetch(source.descriptor).then((response) => {
      if (!response.ok) throw new Error(`Unable to load ${source.descriptor}`);
      return response.text();
    }),
    loadImage(source.atlas),
  ]);
  const parsed = parseDescriptor(descriptor);
  return { ...parsed, mask: createAlphaMask(image), tinted: new Map() };
}

function parseDescriptor(descriptor) {
  let lineHeight = 0;
  const characters = new Map();
  for (const line of descriptor.split(/\r?\n/)) {
    if (line.startsWith("common ")) {
      lineHeight = readNumber(line, "lineHeight");
    } else if (line.startsWith("char id=")) {
      const id = readNumber(line, "id");
      characters.set(String.fromCodePoint(id), {
        x: readNumber(line, "x"),
        y: readNumber(line, "y"),
        width: readNumber(line, "width"),
        height: readNumber(line, "height"),
        xoffset: readNumber(line, "xoffset"),
        yoffset: readNumber(line, "yoffset"),
        xadvance: readNumber(line, "xadvance"),
      });
    }
  }
  if (!lineHeight || characters.size === 0) throw new Error("Invalid BMFont descriptor");
  return { lineHeight, characters };
}

function readNumber(line, key) {
  const match = line.match(new RegExp(`(?:^|\\s)${key}=(-?\\d+)`));
  return match ? Number(match[1]) : 0;
}

function loadImage(url) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => resolve(image);
    image.onerror = () => reject(new Error(`Unable to load ${url}`));
    image.src = url;
  });
}

function createAlphaMask(image) {
  const canvas = document.createElement("canvas");
  canvas.width = image.naturalWidth;
  canvas.height = image.naturalHeight;
  const context = canvas.getContext("2d", { willReadFrequently: true });
  context.drawImage(image, 0, 0);
  const pixels = context.getImageData(0, 0, canvas.width, canvas.height);
  for (let index = 0; index < pixels.data.length; index += 4) {
    const alpha = pixels.data[index];
    pixels.data[index] = 255;
    pixels.data[index + 1] = 255;
    pixels.data[index + 2] = 255;
    pixels.data[index + 3] = alpha;
  }
  context.putImageData(pixels, 0, 0);
  return canvas;
}

function tintedAtlas(font, color) {
  const normalized = color.toUpperCase();
  if (font.tinted.has(normalized)) return font.tinted.get(normalized);
  const canvas = document.createElement("canvas");
  canvas.width = font.mask.width;
  canvas.height = font.mask.height;
  const context = canvas.getContext("2d");
  context.drawImage(font.mask, 0, 0);
  context.globalCompositeOperation = "source-in";
  context.fillStyle = normalized;
  context.fillRect(0, 0, canvas.width, canvas.height);
  font.tinted.set(normalized, canvas);
  return canvas;
}
