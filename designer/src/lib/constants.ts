import type { ElementType, FontType } from '@/store/types'

export const WATCH_WIDTH = 320
export const WATCH_HEIGHT = 360
export const WATCH_BEZEL_RADIUS = 40

export interface ElementDefinition {
  type: ElementType
  name: string
  icon: string
  description: string
  defaultWidth: number
  defaultHeight: number
}

export const ELEMENT_DEFINITIONS: ElementDefinition[] = [
  {
    type: 'time-digital',
    name: 'Digital Time',
    icon: 'clock',
    description: 'Digital clock display',
    defaultWidth: 200,
    defaultHeight: 80,
  },
  {
    type: 'time-analog',
    name: 'Analog Clock',
    icon: 'watch',
    description: 'Analog clock with hands',
    defaultWidth: 200,
    defaultHeight: 200,
  },
  {
    type: 'date',
    name: 'Date',
    icon: 'calendar',
    description: 'Date display',
    defaultWidth: 150,
    defaultHeight: 40,
  },
  {
    type: 'battery',
    name: 'Battery',
    icon: 'battery',
    description: 'Battery level indicator',
    defaultWidth: 50,
    defaultHeight: 24,
  },
  {
    type: 'steps',
    name: 'Steps',
    icon: 'footprints',
    description: 'Step counter',
    defaultWidth: 80,
    defaultHeight: 40,
  },
  {
    type: 'heart-rate',
    name: 'Heart Rate',
    icon: 'heart',
    description: 'Heart rate display',
    defaultWidth: 60,
    defaultHeight: 40,
  },
  {
    type: 'progress-bar',
    name: 'Progress Bar',
    icon: 'loader',
    description: 'Progress bar or arc',
    defaultWidth: 100,
    defaultHeight: 10,
  },
  {
    type: 'shape',
    name: 'Shape',
    icon: 'square',
    description: 'Rectangle, circle, line, or arc',
    defaultWidth: 100,
    defaultHeight: 100,
  },
  {
    type: 'text',
    name: 'Text',
    icon: 'type',
    description: 'Custom text label',
    defaultWidth: 100,
    defaultHeight: 30,
  },
  {
    type: 'background',
    name: 'Background',
    icon: 'image',
    description: 'Background color or image',
    defaultWidth: WATCH_WIDTH,
    defaultHeight: WATCH_HEIGHT,
  },
]

export const FONT_OPTIONS: { value: FontType; label: string; monkeyCName: string }[] = [
  { value: 'system-hot', label: 'System Hot (Large)', monkeyCName: 'Graphics.FONT_SYSTEM_NUMBER_HOT' },
  { value: 'system-medium', label: 'System Medium', monkeyCName: 'Graphics.FONT_SYSTEM_NUMBER_MEDIUM' },
  { value: 'system-small', label: 'System Small', monkeyCName: 'Graphics.FONT_SMALL' },
  { value: 'system-tiny', label: 'System Tiny', monkeyCName: 'Graphics.FONT_TINY' },
  { value: 'pixel', label: 'Pixel Font', monkeyCName: 'PixelFont' },
]

export const DAY_NAMES = ['', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
export const MONTH_NAMES = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
