import { v4 as uuid } from 'uuid'
import {
  Clock,
  Watch,
  Calendar,
  Battery,
  Footprints,
  Heart,
  Loader,
  Square,
  Type,
  Image,
} from 'lucide-react'
import { Card } from '@/components/ui/card'
import { ScrollArea } from '@/components/ui/scroll-area'
import { useDesignerStore } from '@/store'
import { ELEMENT_DEFINITIONS, WATCH_WIDTH, WATCH_HEIGHT } from '@/lib/constants'
import type { ElementType, WatchElement, ElementProperties } from '@/store/types'

const ICONS: Record<string, React.ComponentType<{ className?: string }>> = {
  clock: Clock,
  watch: Watch,
  calendar: Calendar,
  battery: Battery,
  footprints: Footprints,
  heart: Heart,
  loader: Loader,
  square: Square,
  type: Type,
  image: Image,
}

function createDefaultElement(type: ElementType): WatchElement {
  const def = ELEMENT_DEFINITIONS.find((d) => d.type === type)!
  const id = uuid()

  const baseProperties: ElementProperties = {
    id,
    type,
    name: def.name,
    x: Math.floor((WATCH_WIDTH - def.defaultWidth) / 2),
    y: Math.floor((WATCH_HEIGHT - def.defaultHeight) / 2),
    width: def.defaultWidth,
    height: def.defaultHeight,
    zIndex: 0,
    visible: true,
    locked: false,
    color: '#FFFFFF',
    backgroundColor: 'transparent',
    opacity: 1,
  }

  // Type-specific defaults
  switch (type) {
    case 'time-digital':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          font: 'system-hot',
          format24h: true,
          showSeconds: false,
          textAlign: 'center',
        },
      }
    case 'time-analog':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          showSecondHand: true,
          hourHandLength: 50,
          minuteHandLength: 75,
          secondHandLength: 80,
          hourHandWidth: 6,
          minuteHandWidth: 4,
          secondHandWidth: 2,
          hourHandColor: '#FFFFFF',
          minuteHandColor: '#FFFFFF',
          secondHandColor: '#FF6600',
          centerDotRadius: 8,
          centerDotColor: '#FFFFFF',
        },
      }
    case 'date':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          font: 'system-small',
          textAlign: 'center',
        },
      }
    case 'battery':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          color: '#00FF00',
        },
      }
    case 'steps':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          font: 'system-small',
          color: '#FFAA00',
        },
      }
    case 'heart-rate':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          font: 'system-small',
          color: '#FF4444',
        },
      }
    case 'progress-bar':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          progressType: 'linear',
          progressValue: 75,
          progressMax: 100,
          progressColor: '#FFFFFF',
          progressBackgroundColor: '#333333',
        },
      }
    case 'shape':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          shapeType: 'rectangle',
          strokeWidth: 2,
          strokeColor: '#FFFFFF',
          fillColor: 'transparent',
          cornerRadius: 0,
        },
      }
    case 'text':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          text: 'Label',
          font: 'system-small',
          textAlign: 'center',
        },
      }
    case 'background':
      return {
        id,
        type,
        properties: {
          ...baseProperties,
          x: 0,
          y: 0,
          width: WATCH_WIDTH,
          height: WATCH_HEIGHT,
          zIndex: -100,
          backgroundColor: '#000000',
        },
      }
    default:
      return { id, type, properties: baseProperties }
  }
}

export function ElementPalette() {
  const { addElement, project } = useDesignerStore()

  const handleAddElement = (type: ElementType) => {
    if (!project) return
    const element = createDefaultElement(type)
    // Set zIndex to be on top of existing elements
    element.properties.zIndex = project.elements.length
    addElement(element)
  }

  return (
    <div className="flex flex-col h-full">
      <div className="px-4 py-3 border-b border-border">
        <h3 className="text-sm font-medium">Elements</h3>
        <p className="text-xs text-muted-foreground mt-1">
          Click to add to canvas
        </p>
      </div>

      <ScrollArea className="flex-1">
        <div className="p-3 grid grid-cols-2 gap-2">
          {ELEMENT_DEFINITIONS.map((def) => {
            const Icon = ICONS[def.icon] || Square
            return (
              <Card
                key={def.type}
                className="p-3 flex flex-col items-center gap-2 cursor-pointer hover:bg-accent transition-colors"
                onClick={() => handleAddElement(def.type)}
                title={def.description}
              >
                <Icon className="h-6 w-6 text-muted-foreground" />
                <span className="text-xs text-center">{def.name}</span>
              </Card>
            )
          })}
        </div>
      </ScrollArea>
    </div>
  )
}
