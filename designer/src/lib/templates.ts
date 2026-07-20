/**
 * Pre-built watch face templates
 */

import { v4 as uuid } from 'uuid'
import type { WatchFaceProject, WatchElement } from '@/store/types'
import { WATCH_WIDTH, WATCH_HEIGHT } from './constants'

export interface Template {
  id: string
  name: string
  description: string
  preview: string // emoji or icon identifier
  create: () => WatchFaceProject
}

const createDefaultTheme = () => ({
  name: 'Default',
  colors: {
    primary: '#FFFFFF',
    secondary: '#888888',
    accent: '#FFAA00',
    background: '#000000',
    text: '#FFFFFF',
    muted: '#444444',
  },
})

const createElement = (
  type: WatchElement['type'],
  name: string,
  props: Partial<WatchElement['properties']>
): WatchElement => {
  const id = uuid()
  return {
    id,
    type,
    properties: {
      x: 0,
      y: 0,
      width: 100,
      height: 40,
      visible: true,
      locked: false,
      zIndex: 0,
      ...props,
      id,
      type,
      name,
    },
  }
}

// Digital Minimal Template
const createDigitalMinimal = (): WatchFaceProject => {
  const cx = WATCH_WIDTH / 2
  const cy = WATCH_HEIGHT / 2

  return {
    id: uuid(),
    name: 'Digital Minimal',
    settings: {
      name: 'Digital Minimal',
      targetDevice: 'venusq2',
    },
    elements: [
      createElement('background', 'Background', {
        x: 0,
        y: 0,
        width: WATCH_WIDTH,
        height: WATCH_HEIGHT,
        backgroundColor: '#000000',
        zIndex: 0,
      }),
      createElement('time-digital', 'Time', {
        x: cx - 120,
        y: cy - 50,
        width: 240,
        height: 80,
        color: '#FFFFFF',
        font: 'system-hot',
        format24h: false,
        showSeconds: false,
        zIndex: 1,
      }),
      createElement('date', 'Date', {
        x: cx - 60,
        y: cy + 40,
        width: 120,
        height: 30,
        color: '#888888',
        font: 'system-small',
        zIndex: 2,
      }),
      createElement('battery', 'Battery', {
        x: WATCH_WIDTH - 50,
        y: 20,
        width: 30,
        height: 14,
        color: '#FFFFFF',
        zIndex: 3,
      }),
    ],
    theme: createDefaultTheme(),
  }
}

// Fitness Focus Template
const createFitnessFocus = (): WatchFaceProject => {
  const cx = WATCH_WIDTH / 2

  return {
    id: uuid(),
    name: 'Fitness Focus',
    settings: {
      name: 'Fitness Focus',
      targetDevice: 'venusq2',
    },
    elements: [
      createElement('background', 'Background', {
        x: 0,
        y: 0,
        width: WATCH_WIDTH,
        height: WATCH_HEIGHT,
        backgroundColor: '#0a0a0a',
        zIndex: 0,
      }),
      createElement('time-digital', 'Time', {
        x: cx - 100,
        y: 60,
        width: 200,
        height: 60,
        color: '#FFFFFF',
        font: 'system-hot',
        format24h: true,
        showSeconds: false,
        zIndex: 1,
      }),
      createElement('date', 'Date', {
        x: cx - 50,
        y: 20,
        width: 100,
        height: 24,
        color: '#666666',
        font: 'system-tiny',
        zIndex: 2,
      }),
      createElement('steps', 'Steps', {
        x: cx - 60,
        y: 150,
        width: 120,
        height: 40,
        color: '#00FF88',
        font: 'system-medium',
        zIndex: 3,
      }),
      createElement('progress-bar', 'Steps Progress', {
        x: 40,
        y: 200,
        width: WATCH_WIDTH - 80,
        height: 8,
        progressType: 'linear',
        progressValue: 65,
        progressMax: 100,
        progressColor: '#00FF88',
        progressBackgroundColor: '#222222',
        zIndex: 4,
      }),
      createElement('heart-rate', 'Heart Rate', {
        x: cx - 40,
        y: 240,
        width: 80,
        height: 40,
        color: '#FF4444',
        font: 'system-medium',
        zIndex: 5,
      }),
      createElement('battery', 'Battery', {
        x: cx - 20,
        y: WATCH_HEIGHT - 40,
        width: 40,
        height: 16,
        color: '#444444',
        zIndex: 6,
      }),
    ],
    theme: createDefaultTheme(),
  }
}

// Classic Analog Template
const createClassicAnalog = (): WatchFaceProject => {
  const cx = WATCH_WIDTH / 2
  const cy = WATCH_HEIGHT / 2

  return {
    id: uuid(),
    name: 'Classic Analog',
    settings: {
      name: 'Classic Analog',
      targetDevice: 'venusq2',
    },
    elements: [
      createElement('background', 'Background', {
        x: 0,
        y: 0,
        width: WATCH_WIDTH,
        height: WATCH_HEIGHT,
        backgroundColor: '#0d0d0d',
        zIndex: 0,
      }),
      createElement('shape', 'Dial Ring', {
        x: 30,
        y: 50,
        width: WATCH_WIDTH - 60,
        height: WATCH_WIDTH - 60,
        shapeType: 'circle',
        strokeColor: '#333333',
        strokeWidth: 2,
        fillColor: 'transparent',
        zIndex: 1,
      }),
      createElement('time-analog', 'Clock Hands', {
        x: cx - 100,
        y: cy - 80,
        width: 200,
        height: 200,
        showSecondHand: true,
        hourHandLength: 50,
        minuteHandLength: 75,
        secondHandLength: 85,
        hourHandWidth: 6,
        minuteHandWidth: 4,
        secondHandWidth: 2,
        hourHandColor: '#FFFFFF',
        minuteHandColor: '#FFFFFF',
        secondHandColor: '#FF6600',
        centerDotRadius: 6,
        centerDotColor: '#FF6600',
        zIndex: 2,
      }),
      createElement('date', 'Date', {
        x: cx + 30,
        y: cy - 10,
        width: 60,
        height: 20,
        color: '#888888',
        font: 'system-tiny',
        zIndex: 3,
      }),
    ],
    theme: createDefaultTheme(),
  }
}

// Bold & Colorful Template
const createBoldColorful = (): WatchFaceProject => {
  const cx = WATCH_WIDTH / 2

  return {
    id: uuid(),
    name: 'Bold & Colorful',
    settings: {
      name: 'Bold & Colorful',
      targetDevice: 'venusq2',
    },
    elements: [
      createElement('background', 'Background', {
        x: 0,
        y: 0,
        width: WATCH_WIDTH,
        height: WATCH_HEIGHT,
        backgroundColor: '#1a0a2e',
        zIndex: 0,
      }),
      createElement('shape', 'Accent Bar Top', {
        x: 0,
        y: 0,
        width: WATCH_WIDTH,
        height: 4,
        shapeType: 'rectangle',
        fillColor: '#FF00FF',
        strokeColor: 'transparent',
        zIndex: 1,
      }),
      createElement('time-digital', 'Time', {
        x: cx - 130,
        y: 100,
        width: 260,
        height: 90,
        color: '#00FFFF',
        font: 'system-hot',
        format24h: true,
        showSeconds: false,
        zIndex: 2,
      }),
      createElement('date', 'Date', {
        x: cx - 80,
        y: 60,
        width: 160,
        height: 30,
        color: '#FF00FF',
        font: 'system-small',
        zIndex: 3,
      }),
      createElement('progress-bar', 'Steps Arc', {
        x: 40,
        y: 220,
        width: 100,
        height: 100,
        progressType: 'arc',
        progressValue: 75,
        progressMax: 100,
        progressColor: '#00FF88',
        progressBackgroundColor: '#1a2a1a',
        zIndex: 4,
      }),
      createElement('progress-bar', 'HR Arc', {
        x: WATCH_WIDTH - 140,
        y: 220,
        width: 100,
        height: 100,
        progressType: 'arc',
        progressValue: 60,
        progressMax: 100,
        progressColor: '#FF4444',
        progressBackgroundColor: '#2a1a1a',
        zIndex: 5,
      }),
      createElement('steps', 'Steps', {
        x: 55,
        y: 255,
        width: 70,
        height: 30,
        color: '#00FF88',
        font: 'system-tiny',
        zIndex: 6,
      }),
      createElement('heart-rate', 'Heart Rate', {
        x: WATCH_WIDTH - 125,
        y: 255,
        width: 70,
        height: 30,
        color: '#FF4444',
        font: 'system-tiny',
        zIndex: 7,
      }),
    ],
    theme: createDefaultTheme(),
  }
}

// Empty Canvas Template
const createEmptyCanvas = (): WatchFaceProject => ({
  id: uuid(),
  name: 'Empty Canvas',
  settings: {
    name: 'Empty Canvas',
    targetDevice: 'venusq2',
  },
  elements: [
    createElement('background', 'Background', {
      x: 0,
      y: 0,
      width: WATCH_WIDTH,
      height: WATCH_HEIGHT,
      backgroundColor: '#000000',
      zIndex: 0,
    }),
  ],
  theme: createDefaultTheme(),
})

export const templates: Template[] = [
  {
    id: 'digital-minimal',
    name: 'Digital Minimal',
    description: 'Clean digital time with date and battery',
    preview: '⌚',
    create: createDigitalMinimal,
  },
  {
    id: 'fitness-focus',
    name: 'Fitness Focus',
    description: 'Steps, heart rate, and progress tracking',
    preview: '💪',
    create: createFitnessFocus,
  },
  {
    id: 'classic-analog',
    name: 'Classic Analog',
    description: 'Traditional analog clock hands',
    preview: '🕐',
    create: createClassicAnalog,
  },
  {
    id: 'bold-colorful',
    name: 'Bold & Colorful',
    description: 'Vibrant colors with arc gauges',
    preview: '🎨',
    create: createBoldColorful,
  },
  {
    id: 'empty',
    name: 'Empty Canvas',
    description: 'Start from scratch',
    preview: '📝',
    create: createEmptyCanvas,
  },
]
