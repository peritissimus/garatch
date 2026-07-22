// Build BMFont atlases (.fnt + grayscale .png) for a watch-face family from a
// TTF, matching the format the designer preview and Garmin export expect.
//
//   node scripts/build_font_assets.mjs <ttf-file> <prefix> ["Face Name"]
//
// <ttf-file> is a filename inside ui/assets/fonts/. <prefix> is the asset stem
// used everywhere else (e.g. "dseg7_classic" → dseg7_classic_time_88.fnt).
// Glyphs are rasterized from vector outlines (opentype.js) via resvg, so no
// system fonts or native canvas are involved.

import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import { fileURLToPath } from "node:url";
import opentype from "opentype.js";
import { Resvg } from "@resvg/resvg-js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
// Fonts live in two mirrored trees: ui/assets/fonts is globbed by the Vite
// preview, assets/fonts is include_bytes!-d by the Rust exporter. Read from the
// first; write every generated file to both so they stay in sync.
const FONT_DIRS = [
  path.join(__dirname, "..", "ui", "assets", "fonts"),
  path.join(__dirname, "..", "assets", "fonts"),
];
const FONT_DIR = FONT_DIRS[0];

function writeAsset(name, buf) {
  for (const dir of FONT_DIRS) fs.writeFileSync(path.join(dir, name), buf);
}

// Roles and sizes must match ui/lib/bmfont.js FONT_HEIGHT_OPTIONS.
const ROLE_SIZES = {
  time: [72, 88, 104, 120],
  value: [24, 30, 36, 42],
  label: [14, 18, 22, 26],
};

// Per-role glyph subsets, matching the existing atlases.
const CHARSETS = {
  time: "0123456789:",
  value: "%+,-./0123456789",
  label: " !%()+,-./0123456789:?ABCDEFGHIJKLMNOPQRSTUVWXYZ[]abcdefghijklmnopqrstuvwxyz",
};

const ATLAS_W = { time: 512, value: 256, label: 256 };
const MARGIN = 4;
const GAP = 4;

function buildAtlas(font, prefix, role, size) {
  const scale = size / font.unitsPerEm;
  const base = Math.round(font.ascender * scale);
  const lineHeight = Math.round((font.ascender - font.descender) * scale);
  const atlasW = ATLAS_W[role];

  const glyphs = [];
  for (const ch of CHARSETS[role]) {
    const glyph = font.charToGlyph(ch);
    if (!glyph || glyph.index === 0) continue; // .notdef → font lacks this glyph
    const code = ch.codePointAt(0);
    const advance = Math.round((glyph.advanceWidth ?? 0) * scale);
    const p = glyph.getPath(0, base, size);
    const bb = p.getBoundingBox();
    const hasInk = Number.isFinite(bb.x1) && bb.x2 > bb.x1 && bb.y2 > bb.y1;
    if (hasInk) {
      const xoffset = Math.floor(bb.x1);
      const yoffset = Math.floor(bb.y1);
      glyphs.push({
        code, advance, xoffset, yoffset,
        width: Math.ceil(bb.x2) - xoffset,
        height: Math.ceil(bb.y2) - yoffset,
        pathData: p.toPathData(2),
        hasInk: true,
      });
    } else {
      glyphs.push({ code, advance, xoffset: 0, yoffset: 0, width: 0, height: 0, pathData: "", hasInk: false });
    }
  }

  // Shelf-pack ink glyphs into rows.
  let x = MARGIN, y = MARGIN, rowH = 0;
  for (const g of glyphs) {
    if (!g.hasInk) { g.px = 0; g.py = 0; continue; }
    if (x + g.width + MARGIN > atlasW) { x = MARGIN; y += rowH + GAP; rowH = 0; }
    g.px = x; g.py = y;
    x += g.width + GAP;
    rowH = Math.max(rowH, g.height);
  }
  const atlasH = Math.max(8, Math.ceil((y + rowH + MARGIN) / 4) * 4);

  // One SVG: white glyphs on black; grayscale value = coverage.
  let svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${atlasW}" height="${atlasH}" viewBox="0 0 ${atlasW} ${atlasH}">`;
  svg += `<rect width="${atlasW}" height="${atlasH}" fill="#000000"/>`;
  for (const g of glyphs) {
    if (!g.hasInk) continue;
    svg += `<path d="${g.pathData}" fill="#ffffff" transform="translate(${g.px - g.xoffset} ${g.py - g.yoffset})"/>`;
  }
  svg += `</svg>`;

  const rendered = new Resvg(svg, { fitTo: { mode: "original" } }).render();
  const rgba = rendered.pixels;
  const gray = Buffer.alloc(atlasW * atlasH);
  for (let i = 0; i < gray.length; i++) gray[i] = rgba[i * 4]; // R channel = coverage

  const stem = `${prefix}_${role}_${size}`;
  writeAsset(`${stem}.png`, encodeGrayPng(atlasW, atlasH, gray));

  const faceName = font.names.fontFamily?.en ?? prefix;
  let fnt = `info face="${faceName}" size=${size} bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=0,0\n`;
  fnt += `common lineHeight=${lineHeight} base=${base} scaleW=${atlasW} scaleH=${atlasH} pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0\n`;
  fnt += `page id=0 file="${stem}.png"\n`;
  fnt += `chars count=${glyphs.length}\n`;
  for (const g of glyphs) {
    fnt += `char id=${g.code} x=${g.px} y=${g.py} width=${g.width} height=${g.height} xoffset=${g.xoffset} yoffset=${g.yoffset} xadvance=${g.advance} page=0 chnl=15\n`;
  }
  writeAsset(`${stem}.fnt`, Buffer.from(fnt, "utf8"));
  return { stem, glyphs: glyphs.length, atlasW, atlasH };
}

// Minimal 8-bit grayscale PNG encoder (color type 0).
function encodeGrayPng(w, h, data) {
  const raw = Buffer.alloc((w + 1) * h);
  for (let row = 0; row < h; row++) {
    raw[row * (w + 1)] = 0; // filter: none
    data.copy(raw, row * (w + 1) + 1, row * w, row * w + w);
  }
  const idat = zlib.deflateSync(raw, { level: 9 });
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 0; // color type: grayscale
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([sig, pngChunk("IHDR", ihdr), pngChunk("IDAT", idat), pngChunk("IEND", Buffer.alloc(0))]);
}

function pngChunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, "ascii");
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])) >>> 0, 0);
  return Buffer.concat([len, typeBuf, data, crc]);
}

const CRC_TABLE = (() => {
  const table = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    table[n] = c >>> 0;
  }
  return table;
})();

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

const [ttfFile, prefix, faceOverride] = process.argv.slice(2);
if (!ttfFile || !prefix) {
  console.error('Usage: node scripts/build_font_assets.mjs <ttf-file> <prefix> ["Face Name"]');
  process.exit(1);
}
const font = opentype.parse(fs.readFileSync(path.join(FONT_DIR, ttfFile)));
if (faceOverride) font.names.fontFamily = { en: faceOverride };
console.log(`Building ${prefix} from ${ttfFile} (unitsPerEm=${font.unitsPerEm})`);
for (const [role, sizes] of Object.entries(ROLE_SIZES)) {
  for (const size of sizes) {
    const r = buildAtlas(font, prefix, role, size);
    console.log(`  ${r.stem}: ${r.glyphs} glyphs, ${r.atlasW}x${r.atlasH}`);
  }
}
console.log("Done.");
