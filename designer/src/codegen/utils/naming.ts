/**
 * Naming utilities for code generation
 */

/**
 * Convert a project name to a valid MonkeyC class name
 * e.g., "my-cool-face" -> "MyCoolFace"
 */
export function toClassName(name: string): string {
  return name
    .split(/[-_\s]+/)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join('')
    .replace(/[^a-zA-Z0-9]/g, '')
}

/**
 * Convert a project name to a folder name
 * e.g., "My Cool Face" -> "my-cool-face"
 */
export function toFolderName(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}

/**
 * Generate a unique app ID (UUID format)
 */
export function generateAppId(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0
    const v = c === 'x' ? r : (r & 0x3) | 0x8
    return v.toString(16)
  })
}

/**
 * Convert element name to a valid function name
 * e.g., "Digital Time" -> "drawDigitalTime"
 */
export function toFunctionName(name: string, prefix: string = 'draw'): string {
  const camelCase = name
    .split(/[-_\s]+/)
    .map((word, i) =>
      i === 0
        ? word.toLowerCase()
        : word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    )
    .join('')
    .replace(/[^a-zA-Z0-9]/g, '')

  return prefix + camelCase.charAt(0).toUpperCase() + camelCase.slice(1)
}
