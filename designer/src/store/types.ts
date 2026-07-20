export type ElementType =
  | 'time-digital'
  | 'time-analog'
  | 'date'
  | 'battery'
  | 'steps'
  | 'heart-rate'
  | 'progress-bar'
  | 'shape'
  | 'text'
  | 'background'

export type ShapeType = 'rectangle' | 'circle' | 'line' | 'arc'
export type FontType = 'system-hot' | 'system-medium' | 'system-small' | 'system-tiny' | 'pixel'
export type TextAlign = 'left' | 'center' | 'right'

export interface Position {
  x: number
  y: number
}

export interface Size {
  width: number
  height: number
}

export interface ElementProperties {
  // Common properties
  id: string
  type: ElementType
  name: string
  x: number
  y: number
  width: number
  height: number
  zIndex: number
  visible: boolean
  locked: boolean

  // Appearance
  color?: string
  backgroundColor?: string
  opacity?: number

  // Text properties
  font?: FontType
  fontSize?: number
  textAlign?: TextAlign
  text?: string

  // Shape properties
  shapeType?: ShapeType
  strokeWidth?: number
  strokeColor?: string
  fillColor?: string
  cornerRadius?: number

  // Time digital properties
  format24h?: boolean
  showSeconds?: boolean

  // Time analog properties
  showSecondHand?: boolean
  hourHandLength?: number
  minuteHandLength?: number
  secondHandLength?: number
  hourHandWidth?: number
  minuteHandWidth?: number
  secondHandWidth?: number
  hourHandColor?: string
  minuteHandColor?: string
  secondHandColor?: string
  centerDotRadius?: number
  centerDotColor?: string

  // Progress bar
  progressType?: 'linear' | 'arc'
  progressValue?: number
  progressMax?: number
  progressColor?: string
  progressBackgroundColor?: string
}

export interface WatchElement {
  id: string
  type: ElementType
  properties: ElementProperties
}

export interface ThemeColors {
  primary: string
  secondary: string
  accent: string
  background: string
  text: string
  muted: string
}

export interface ThemeConfig {
  name: string
  colors: ThemeColors
}

export interface ProjectSettings {
  name: string
  targetDevice: 'venusq2' | 'venusq2m'
}

export interface WatchFaceProject {
  id: string
  name: string
  settings: ProjectSettings
  elements: WatchElement[]
  theme: ThemeConfig
}

export interface PreviewData {
  time: {
    hour: number
    min: number
    sec: number
  }
  date: {
    day: number
    month: number
    dayOfWeek: number
    year: number
  }
  battery: number
  steps: number
  stepGoal: number
  heartRate: number
}

export interface DesignerState {
  // Project
  project: WatchFaceProject | null
  isDirty: boolean

  // Selection
  selectedElementIds: string[]
  hoveredElementId: string | null

  // Canvas
  zoom: number
  panOffset: Position
  showGrid: boolean
  snapToGrid: boolean
  gridSize: number

  // Preview data
  previewData: PreviewData

  // History
  past: WatchFaceProject[]
  future: WatchFaceProject[]

  // Actions
  newProject: (name: string) => void
  setProject: (project: WatchFaceProject) => void
  addElement: (element: WatchElement) => void
  updateElement: (id: string, properties: Partial<ElementProperties>) => void
  removeElement: (id: string) => void
  duplicateElement: (id: string) => void
  reorderElements: (fromIndex: number, toIndex: number) => void
  selectElements: (ids: string[]) => void
  setHoveredElement: (id: string | null) => void
  toggleElementVisibility: (id: string) => void
  toggleElementLock: (id: string) => void

  // Canvas actions
  setZoom: (zoom: number) => void
  setPanOffset: (offset: Position) => void
  toggleGrid: () => void
  toggleSnapToGrid: () => void

  // Preview actions
  setPreviewData: (data: Partial<PreviewData>) => void

  // History actions
  undo: () => void
  redo: () => void
  saveToHistory: () => void

  // Alignment actions
  alignElements: (alignment: 'left' | 'center-h' | 'right' | 'top' | 'center-v' | 'bottom') => void
  distributeElements: (direction: 'horizontal' | 'vertical') => void
}

// Watch dimensions (Venu Sq 2)
export const WATCH_WIDTH = 320
export const WATCH_HEIGHT = 360
export const WATCH_BEZEL_RADIUS = 40
