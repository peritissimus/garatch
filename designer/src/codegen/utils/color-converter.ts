/**
 * Convert hex color to MonkeyC color format
 */

// Named colors that map to Graphics.COLOR_* constants
const NAMED_COLORS: Record<string, string> = {
  '#FFFFFF': 'Graphics.COLOR_WHITE',
  '#ffffff': 'Graphics.COLOR_WHITE',
  '#000000': 'Graphics.COLOR_BLACK',
  '#FF0000': 'Graphics.COLOR_RED',
  '#ff0000': 'Graphics.COLOR_RED',
  '#00FF00': 'Graphics.COLOR_GREEN',
  '#00ff00': 'Graphics.COLOR_GREEN',
  '#0000FF': 'Graphics.COLOR_BLUE',
  '#0000ff': 'Graphics.COLOR_BLUE',
  '#FFFF00': 'Graphics.COLOR_YELLOW',
  '#ffff00': 'Graphics.COLOR_YELLOW',
  '#FFA500': 'Graphics.COLOR_ORANGE',
  '#ffa500': 'Graphics.COLOR_ORANGE',
  '#FFC0CB': 'Graphics.COLOR_PINK',
  '#ffc0cb': 'Graphics.COLOR_PINK',
  '#800080': 'Graphics.COLOR_PURPLE',
  '#00FFFF': 'Graphics.COLOR_CYAN',
  '#00ffff': 'Graphics.COLOR_CYAN',
  '#A9A9A9': 'Graphics.COLOR_DK_GRAY',
  '#a9a9a9': 'Graphics.COLOR_DK_GRAY',
  '#D3D3D3': 'Graphics.COLOR_LT_GRAY',
  '#d3d3d3': 'Graphics.COLOR_LT_GRAY',
}

/**
 * Convert a hex color string to MonkeyC color code
 * @param hex - Color in #RRGGBB format
 * @returns MonkeyC color (either Graphics.COLOR_* constant or 0xRRGGBB literal)
 */
export function hexToMonkeyC(hex: string | undefined): string {
  if (!hex || hex === 'transparent') {
    return 'Graphics.COLOR_TRANSPARENT'
  }

  // Normalize the hex color
  const normalized = hex.toUpperCase()

  // Check for named color
  if (NAMED_COLORS[hex]) {
    return NAMED_COLORS[hex]
  }
  if (NAMED_COLORS[normalized]) {
    return NAMED_COLORS[normalized]
  }

  // Return as hex literal (remove # and prefix with 0x)
  const hexValue = hex.replace('#', '').toUpperCase()
  return `0x${hexValue}`
}

/**
 * Get battery color based on level thresholds (matches existing watch face patterns)
 * @param varName - Variable name holding battery level
 * @returns MonkeyC code for battery color selection
 */
export function getBatteryColorCode(varName: string = 'battery'): string {
  return `
    var batColor = Graphics.COLOR_GREEN;
    if (${varName} <= 20) {
        batColor = Graphics.COLOR_RED;
    } else if (${varName} <= 50) {
        batColor = Graphics.COLOR_YELLOW;
    }`
}
