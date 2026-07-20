/**
 * Map designer font types to MonkeyC font constants
 */

import type { FontType } from '@/store/types'

const FONT_MAP: Record<FontType, string> = {
  'system-hot': 'Graphics.FONT_SYSTEM_NUMBER_HOT',
  'system-medium': 'Graphics.FONT_SYSTEM_NUMBER_MEDIUM',
  'system-small': 'Graphics.FONT_SMALL',
  'system-tiny': 'Graphics.FONT_TINY',
  'pixel': 'Graphics.FONT_XTINY', // Fallback, actual pixel font uses PixelFont module
}

/**
 * Convert designer font type to MonkeyC font constant
 */
export function fontToMonkeyC(font: FontType | undefined): string {
  if (!font) return FONT_MAP['system-small']
  return FONT_MAP[font] || FONT_MAP['system-small']
}

/**
 * Check if the font requires the PixelFont shared module
 */
export function requiresPixelFont(font: FontType | undefined): boolean {
  return font === 'pixel'
}

/**
 * Get text justification code
 */
export function getTextJustification(align: string | undefined): string {
  switch (align) {
    case 'left':
      return 'Graphics.TEXT_JUSTIFY_LEFT'
    case 'right':
      return 'Graphics.TEXT_JUSTIFY_RIGHT'
    case 'center':
    default:
      return 'Graphics.TEXT_JUSTIFY_CENTER'
  }
}

/**
 * Get combined justification for centered text (horizontal + vertical)
 */
export function getCenteredJustification(): string {
  return 'Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER'
}
