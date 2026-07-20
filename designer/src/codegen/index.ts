/**
 * Main code generation module
 * Exports watch face designs to MonkeyC code
 */

import type { WatchFaceProject } from '@/store/types'
import { toClassName, toFolderName } from './utils/naming'
import { generateViewMc } from './templates/ViewTemplate'
import { generateAppMc } from './templates/AppTemplate'
import { generateManifestXml } from './templates/ManifestTemplate'
import { generateMonkeyJungle } from './templates/JungleTemplate'
import {
  generateDrawablesXml,
  generateStringsXml,
  generateLayoutXml,
} from './templates/ResourceTemplates'

export interface GeneratedFile {
  path: string
  content: string
}

export interface ExportResult {
  success: boolean
  folderName: string
  files: GeneratedFile[]
  error?: string
}

/**
 * Generate all files for a watch face project
 */
export function generateWatchFace(project: WatchFaceProject): ExportResult {
  try {
    const folderName = toFolderName(project.name)
    const className = toClassName(project.name)

    const files: GeneratedFile[] = [
      // Source files
      {
        path: `source/${className}App.mc`,
        content: generateAppMc(project),
      },
      {
        path: `source/${className}View.mc`,
        content: generateViewMc(project),
      },

      // Manifest
      {
        path: 'manifest.xml',
        content: generateManifestXml(project),
      },

      // Build config
      {
        path: 'monkey.jungle',
        content: generateMonkeyJungle(project),
      },

      // Resources
      {
        path: 'resources/drawables/drawables.xml',
        content: generateDrawablesXml(),
      },
      {
        path: 'resources/strings/strings.xml',
        content: generateStringsXml(project),
      },
      {
        path: 'resources/layouts/layout.xml',
        content: generateLayoutXml(),
      },
    ]

    return {
      success: true,
      folderName,
      files,
    }
  } catch (error) {
    return {
      success: false,
      folderName: '',
      files: [],
      error: String(error),
    }
  }
}

/**
 * Preview the generated View.mc code (for display in UI)
 */
export function previewViewMc(project: WatchFaceProject): string {
  return generateViewMc(project)
}

/**
 * Get the folder structure that will be created
 */
export function getFolderStructure(project: WatchFaceProject): string[] {
  const folderName = toFolderName(project.name)
  const className = toClassName(project.name)

  return [
    `${folderName}/`,
    `${folderName}/source/`,
    `${folderName}/source/${className}App.mc`,
    `${folderName}/source/${className}View.mc`,
    `${folderName}/manifest.xml`,
    `${folderName}/monkey.jungle`,
    `${folderName}/resources/`,
    `${folderName}/resources/drawables/`,
    `${folderName}/resources/drawables/drawables.xml`,
    `${folderName}/resources/drawables/launcher_icon.png`,
    `${folderName}/resources/strings/`,
    `${folderName}/resources/strings/strings.xml`,
    `${folderName}/resources/layouts/`,
    `${folderName}/resources/layouts/layout.xml`,
  ]
}

// Re-export utilities
export { toClassName, toFolderName } from './utils/naming'
export { hexToMonkeyC } from './utils/color-converter'
export { fontToMonkeyC } from './utils/font-mapper'
