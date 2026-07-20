import { useRef, useEffect, useCallback, useMemo, useState } from 'react'
import { useDesignerStore } from '@/store'
import { WATCH_WIDTH, WATCH_HEIGHT, WATCH_BEZEL_RADIUS } from '@/lib/constants'
import { DAY_NAMES } from '@/lib/constants'
import type { WatchElement, PreviewData } from '@/store/types'

interface DragState {
  isDragging: boolean
  elementId: string | null
  startX: number
  startY: number
  elementStartX: number
  elementStartY: number
  isResizing: boolean
  resizeHandle: string | null
  elementStartWidth: number
  elementStartHeight: number
}

export function WatchCanvas() {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const containerRef = useRef<HTMLDivElement>(null)

  const [dragState, setDragState] = useState<DragState>({
    isDragging: false,
    elementId: null,
    startX: 0,
    startY: 0,
    elementStartX: 0,
    elementStartY: 0,
    isResizing: false,
    resizeHandle: null,
    elementStartWidth: 0,
    elementStartHeight: 0,
  })

  const {
    project,
    zoom,
    showGrid,
    gridSize,
    snapToGrid,
    previewData,
    selectedElementIds,
    selectElements,
    updateElement,
  } = useDesignerStore()

  const elements = useMemo(() => project?.elements ?? [], [project?.elements])

  // Draw the watch face
  const draw = useCallback(() => {
    const canvas = canvasRef.current
    if (!canvas) return

    const ctx = canvas.getContext('2d')
    if (!ctx) return

    // Clear canvas
    ctx.fillStyle = '#000000'
    ctx.fillRect(0, 0, WATCH_WIDTH, WATCH_HEIGHT)

    // Sort elements by zIndex
    const sortedElements = [...elements].sort(
      (a, b) => a.properties.zIndex - b.properties.zIndex
    )

    // Draw each element
    for (const element of sortedElements) {
      if (!element.properties.visible) continue
      drawElement(ctx, element, previewData)
    }

    // Draw grid overlay
    if (showGrid) {
      drawGrid(ctx)
    }

    // Draw selection boxes
    for (const id of selectedElementIds) {
      const element = elements.find((el) => el.id === id)
      if (element) {
        drawSelectionBox(ctx, element)
      }
    }
  }, [elements, previewData, showGrid, selectedElementIds])

  useEffect(() => {
    draw()
  }, [draw])

  // Update canvas every second for time
  useEffect(() => {
    const interval = setInterval(() => {
      const now = new Date()
      useDesignerStore.getState().setPreviewData({
        time: {
          hour: now.getHours(),
          min: now.getMinutes(),
          sec: now.getSeconds(),
        },
      })
    }, 1000)
    return () => clearInterval(interval)
  }, [])

  // Helper to get canvas coordinates from mouse event
  const getCanvasCoords = useCallback((e: React.MouseEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current
    if (!canvas) return { x: 0, y: 0 }

    const rect = canvas.getBoundingClientRect()
    const scaleX = WATCH_WIDTH / rect.width
    const scaleY = WATCH_HEIGHT / rect.height
    return {
      x: (e.clientX - rect.left) * scaleX,
      y: (e.clientY - rect.top) * scaleY,
    }
  }, [])

  // Check if point is on a resize handle
  const getResizeHandle = useCallback((x: number, y: number, element: WatchElement) => {
    const handleSize = 12
    const { x: ex, y: ey, width, height } = element.properties
    const handles = [
      { name: 'nw', x: ex, y: ey },
      { name: 'ne', x: ex + width, y: ey },
      { name: 'sw', x: ex, y: ey + height },
      { name: 'se', x: ex + width, y: ey + height },
    ]

    for (const handle of handles) {
      if (
        x >= handle.x - handleSize / 2 &&
        x <= handle.x + handleSize / 2 &&
        y >= handle.y - handleSize / 2 &&
        y <= handle.y + handleSize / 2
      ) {
        return handle.name
      }
    }
    return null
  }, [])

  // Find element at position
  const findElementAt = useCallback((x: number, y: number) => {
    const sortedElements = [...elements].sort(
      (a, b) => b.properties.zIndex - a.properties.zIndex
    )

    for (const element of sortedElements) {
      const { x: ex, y: ey, width, height, visible, locked } = element.properties
      if (!visible || locked) continue
      if (x >= ex && x <= ex + width && y >= ey && y <= ey + height) {
        return element
      }
    }
    return null
  }, [elements])

  // Snap value to grid if enabled
  const snapValue = useCallback((value: number) => {
    if (!snapToGrid) return value
    return Math.round(value / gridSize) * gridSize
  }, [snapToGrid, gridSize])

  const handleMouseDown = useCallback((e: React.MouseEvent<HTMLCanvasElement>) => {
    const { x, y } = getCanvasCoords(e)

    // Check if clicking on a resize handle of selected element
    if (selectedElementIds.length === 1) {
      const selectedElement = elements.find(el => el.id === selectedElementIds[0])
      if (selectedElement && !selectedElement.properties.locked) {
        const handle = getResizeHandle(x, y, selectedElement)
        if (handle) {
          setDragState({
            isDragging: false,
            elementId: selectedElement.id,
            startX: x,
            startY: y,
            elementStartX: selectedElement.properties.x,
            elementStartY: selectedElement.properties.y,
            isResizing: true,
            resizeHandle: handle,
            elementStartWidth: selectedElement.properties.width,
            elementStartHeight: selectedElement.properties.height,
          })
          return
        }
      }
    }

    // Find clicked element
    const element = findElementAt(x, y)

    if (element) {
      selectElements([element.id])
      setDragState({
        isDragging: true,
        elementId: element.id,
        startX: x,
        startY: y,
        elementStartX: element.properties.x,
        elementStartY: element.properties.y,
        isResizing: false,
        resizeHandle: null,
        elementStartWidth: element.properties.width,
        elementStartHeight: element.properties.height,
      })
    } else {
      selectElements([])
      setDragState({
        isDragging: false,
        elementId: null,
        startX: 0,
        startY: 0,
        elementStartX: 0,
        elementStartY: 0,
        isResizing: false,
        resizeHandle: null,
        elementStartWidth: 0,
        elementStartHeight: 0,
      })
    }
  }, [getCanvasCoords, findElementAt, getResizeHandle, selectedElementIds, elements, selectElements])

  const handleMouseMove = useCallback((e: React.MouseEvent<HTMLCanvasElement>) => {
    if (!dragState.isDragging && !dragState.isResizing) return

    const { x, y } = getCanvasCoords(e)
    const dx = x - dragState.startX
    const dy = y - dragState.startY

    if (dragState.isDragging && dragState.elementId) {
      // Moving element
      let newX = snapValue(dragState.elementStartX + dx)
      let newY = snapValue(dragState.elementStartY + dy)

      // Clamp to canvas bounds
      const element = elements.find(el => el.id === dragState.elementId)
      if (element) {
        newX = Math.max(0, Math.min(WATCH_WIDTH - element.properties.width, newX))
        newY = Math.max(0, Math.min(WATCH_HEIGHT - element.properties.height, newY))
      }

      updateElement(dragState.elementId, { x: newX, y: newY })
    } else if (dragState.isResizing && dragState.elementId && dragState.resizeHandle) {
      // Resizing element
      let newX = dragState.elementStartX
      let newY = dragState.elementStartY
      let newWidth = dragState.elementStartWidth
      let newHeight = dragState.elementStartHeight

      switch (dragState.resizeHandle) {
        case 'se':
          newWidth = snapValue(Math.max(20, dragState.elementStartWidth + dx))
          newHeight = snapValue(Math.max(20, dragState.elementStartHeight + dy))
          break
        case 'sw':
          newX = snapValue(dragState.elementStartX + dx)
          newWidth = Math.max(20, dragState.elementStartWidth - dx)
          newHeight = snapValue(Math.max(20, dragState.elementStartHeight + dy))
          break
        case 'ne':
          newY = snapValue(dragState.elementStartY + dy)
          newWidth = snapValue(Math.max(20, dragState.elementStartWidth + dx))
          newHeight = Math.max(20, dragState.elementStartHeight - dy)
          break
        case 'nw':
          newX = snapValue(dragState.elementStartX + dx)
          newY = snapValue(dragState.elementStartY + dy)
          newWidth = Math.max(20, dragState.elementStartWidth - dx)
          newHeight = Math.max(20, dragState.elementStartHeight - dy)
          break
      }

      updateElement(dragState.elementId, {
        x: newX,
        y: newY,
        width: newWidth,
        height: newHeight,
      })
    }
  }, [dragState, getCanvasCoords, snapValue, elements, updateElement])

  const handleMouseUp = useCallback(() => {
    setDragState({
      isDragging: false,
      elementId: null,
      startX: 0,
      startY: 0,
      elementStartX: 0,
      elementStartY: 0,
      isResizing: false,
      resizeHandle: null,
      elementStartWidth: 0,
      elementStartHeight: 0,
    })
  }, [])

  // Get cursor style based on current state
  const getCursorStyle = useCallback(() => {
    if (dragState.isDragging) return 'grabbing'
    if (dragState.isResizing) {
      switch (dragState.resizeHandle) {
        case 'nw':
        case 'se':
          return 'nwse-resize'
        case 'ne':
        case 'sw':
          return 'nesw-resize'
      }
    }
    return 'crosshair'
  }, [dragState])

  return (
    <div
      ref={containerRef}
      className="flex-1 flex items-center justify-center bg-muted/30 overflow-auto p-8"
    >
      <div
        className="relative"
        style={{
          transform: `scale(${zoom})`,
          transformOrigin: 'center center',
        }}
      >
        {/* Watch bezel frame */}
        <div
          className="absolute -inset-4 rounded-[48px] bg-gradient-to-b from-zinc-700 to-zinc-900 shadow-2xl"
          style={{ borderRadius: WATCH_BEZEL_RADIUS + 8 }}
        />
        <div
          className="absolute -inset-2 rounded-[44px] bg-gradient-to-b from-zinc-800 to-zinc-950"
          style={{ borderRadius: WATCH_BEZEL_RADIUS + 4 }}
        />

        {/* Canvas */}
        <canvas
          ref={canvasRef}
          width={WATCH_WIDTH}
          height={WATCH_HEIGHT}
          className="relative rounded-[40px]"
          style={{ borderRadius: WATCH_BEZEL_RADIUS, cursor: getCursorStyle() }}
          onMouseDown={handleMouseDown}
          onMouseMove={handleMouseMove}
          onMouseUp={handleMouseUp}
          onMouseLeave={handleMouseUp}
        />
      </div>
    </div>
  )
}

function drawElement(
  ctx: CanvasRenderingContext2D,
  element: WatchElement,
  previewData: PreviewData
) {
  const { properties } = element

  switch (element.type) {
    case 'background':
      if (properties.backgroundColor && properties.backgroundColor !== 'transparent') {
        ctx.fillStyle = properties.backgroundColor
        ctx.fillRect(0, 0, WATCH_WIDTH, WATCH_HEIGHT)
      }
      break

    case 'time-digital':
      drawTimeDigital(ctx, properties, previewData)
      break

    case 'time-analog':
      drawTimeAnalog(ctx, properties, previewData)
      break

    case 'date':
      drawDate(ctx, properties, previewData)
      break

    case 'battery':
      drawBattery(ctx, properties, previewData)
      break

    case 'steps':
      drawSteps(ctx, properties, previewData)
      break

    case 'heart-rate':
      drawHeartRate(ctx, properties, previewData)
      break

    case 'shape':
      drawShape(ctx, properties)
      break

    case 'text':
      drawText(ctx, properties)
      break

    case 'progress-bar':
      drawProgressBar(ctx, properties)
      break
  }
}

function drawTimeDigital(
  ctx: CanvasRenderingContext2D,
  props: WatchElement['properties'],
  data: PreviewData
) {
  const { x, y, width, height, color, font, format24h, showSeconds } = props
  const { time } = data

  let hour = time.hour
  if (!format24h && hour > 12) hour -= 12
  if (!format24h && hour === 0) hour = 12

  const hourStr = hour.toString().padStart(2, '0')
  const minStr = time.min.toString().padStart(2, '0')
  const secStr = time.sec.toString().padStart(2, '0')

  let timeStr = `${hourStr}:${minStr}`
  if (showSeconds) timeStr += `:${secStr}`

  ctx.fillStyle = color || '#FFFFFF'
  ctx.font = getFontString(font || 'system-hot')
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText(timeStr, x + width / 2, y + height / 2)
}

function drawTimeAnalog(
  ctx: CanvasRenderingContext2D,
  props: WatchElement['properties'],
  data: PreviewData
) {
  const {
    x,
    y,
    width,
    height,
    showSecondHand,
    hourHandLength = 50,
    minuteHandLength = 75,
    secondHandLength = 80,
    hourHandWidth = 6,
    minuteHandWidth = 4,
    secondHandWidth = 2,
    hourHandColor = '#FFFFFF',
    minuteHandColor = '#FFFFFF',
    secondHandColor = '#FF6600',
    centerDotRadius = 8,
    centerDotColor = '#FFFFFF',
  } = props

  const cx = x + width / 2
  const cy = y + height / 2
  const { time } = data

  // Hour hand
  const hourAngle =
    ((time.hour % 12) * 30 + time.min * 0.5 - 90) * (Math.PI / 180)
  drawHand(ctx, cx, cy, hourAngle, hourHandLength, hourHandWidth, hourHandColor)

  // Minute hand
  const minAngle = (time.min * 6 - 90) * (Math.PI / 180)
  drawHand(ctx, cx, cy, minAngle, minuteHandLength, minuteHandWidth, minuteHandColor)

  // Second hand
  if (showSecondHand) {
    const secAngle = (time.sec * 6 - 90) * (Math.PI / 180)
    drawHand(ctx, cx, cy, secAngle, secondHandLength, secondHandWidth, secondHandColor)
  }

  // Center dot
  ctx.fillStyle = centerDotColor
  ctx.beginPath()
  ctx.arc(cx, cy, centerDotRadius, 0, Math.PI * 2)
  ctx.fill()
}

function drawHand(
  ctx: CanvasRenderingContext2D,
  cx: number,
  cy: number,
  angle: number,
  length: number,
  width: number,
  color: string
) {
  const endX = cx + length * Math.cos(angle)
  const endY = cy + length * Math.sin(angle)

  ctx.strokeStyle = color
  ctx.lineWidth = width
  ctx.lineCap = 'round'
  ctx.beginPath()
  ctx.moveTo(cx, cy)
  ctx.lineTo(endX, endY)
  ctx.stroke()
}

function drawDate(
  ctx: CanvasRenderingContext2D,
  props: WatchElement['properties'],
  data: PreviewData
) {
  const { x, y, width, height, color, font } = props
  const { date } = data

  const dayName = DAY_NAMES[date.dayOfWeek] || 'Mon'
  const dateStr = `${dayName} ${date.day}`

  ctx.fillStyle = color || '#FFFFFF'
  ctx.font = getFontString(font || 'system-small')
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText(dateStr, x + width / 2, y + height / 2)
}

function drawBattery(
  ctx: CanvasRenderingContext2D,
  props: WatchElement['properties'],
  data: PreviewData
) {
  const { x, y, width, height, color } = props
  const battery = data.battery

  // Battery outline
  ctx.strokeStyle = color || '#FFFFFF'
  ctx.lineWidth = 2
  ctx.strokeRect(x, y, width - 4, height)

  // Battery cap
  ctx.fillStyle = color || '#FFFFFF'
  ctx.fillRect(x + width - 4, y + height / 4, 4, height / 2)

  // Battery fill
  const fillColor =
    battery <= 20 ? '#FF4444' : battery <= 50 ? '#FFAA00' : '#00FF00'
  ctx.fillStyle = fillColor
  const fillWidth = ((width - 8) * battery) / 100
  ctx.fillRect(x + 2, y + 2, fillWidth, height - 4)
}

function drawSteps(
  ctx: CanvasRenderingContext2D,
  props: WatchElement['properties'],
  data: PreviewData
) {
  const { x, y, width, height, color, font } = props

  ctx.fillStyle = color || '#FFAA00'
  ctx.font = getFontString(font || 'system-small')
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText(data.steps.toLocaleString(), x + width / 2, y + height / 2)
}

function drawHeartRate(
  ctx: CanvasRenderingContext2D,
  props: WatchElement['properties'],
  data: PreviewData
) {
  const { x, y, width, height, color, font } = props

  ctx.fillStyle = color || '#FF4444'
  ctx.font = getFontString(font || 'system-small')
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText(`${data.heartRate}`, x + width / 2, y + height / 2)
}

function drawShape(ctx: CanvasRenderingContext2D, props: WatchElement['properties']) {
  const {
    x,
    y,
    width,
    height,
    shapeType,
    strokeWidth = 2,
    strokeColor = '#FFFFFF',
    fillColor,
    cornerRadius = 0,
  } = props

  ctx.lineWidth = strokeWidth

  switch (shapeType) {
    case 'rectangle':
      if (fillColor && fillColor !== 'transparent') {
        ctx.fillStyle = fillColor
        if (cornerRadius > 0) {
          roundRect(ctx, x, y, width, height, cornerRadius)
          ctx.fill()
        } else {
          ctx.fillRect(x, y, width, height)
        }
      }
      if (strokeColor && strokeColor !== 'transparent') {
        ctx.strokeStyle = strokeColor
        if (cornerRadius > 0) {
          roundRect(ctx, x, y, width, height, cornerRadius)
          ctx.stroke()
        } else {
          ctx.strokeRect(x, y, width, height)
        }
      }
      break

    case 'circle': {
      const cx = x + width / 2
      const cy = y + height / 2
      const rx = width / 2
      const ry = height / 2
      ctx.beginPath()
      ctx.ellipse(cx, cy, rx, ry, 0, 0, Math.PI * 2)
      if (fillColor && fillColor !== 'transparent') {
        ctx.fillStyle = fillColor
        ctx.fill()
      }
      if (strokeColor && strokeColor !== 'transparent') {
        ctx.strokeStyle = strokeColor
        ctx.stroke()
      }
      break
    }

    case 'line':
      ctx.strokeStyle = strokeColor || '#FFFFFF'
      ctx.beginPath()
      ctx.moveTo(x, y)
      ctx.lineTo(x + width, y + height)
      ctx.stroke()
      break
  }
}

function drawText(ctx: CanvasRenderingContext2D, props: WatchElement['properties']) {
  const { x, y, width, height, color, font, text, textAlign } = props

  ctx.fillStyle = color || '#FFFFFF'
  ctx.font = getFontString(font || 'system-small')
  ctx.textBaseline = 'middle'

  let textX = x
  if (textAlign === 'center') {
    ctx.textAlign = 'center'
    textX = x + width / 2
  } else if (textAlign === 'right') {
    ctx.textAlign = 'right'
    textX = x + width
  } else {
    ctx.textAlign = 'left'
  }

  ctx.fillText(text || '', textX, y + height / 2)
}

function drawProgressBar(
  ctx: CanvasRenderingContext2D,
  props: WatchElement['properties']
) {
  const {
    x,
    y,
    width,
    height,
    progressType,
    progressValue = 50,
    progressMax = 100,
    progressColor = '#FFFFFF',
    progressBackgroundColor = '#333333',
  } = props

  const pct = Math.min(progressValue / progressMax, 1)

  if (progressType === 'arc') {
    // Arc progress
    const cx = x + width / 2
    const cy = y + height / 2
    const radius = Math.min(width, height) / 2 - 4
    const startAngle = -Math.PI / 2
    const endAngle = startAngle + Math.PI * 2 * pct

    ctx.lineWidth = 8
    ctx.lineCap = 'round'

    // Background arc
    ctx.strokeStyle = progressBackgroundColor
    ctx.beginPath()
    ctx.arc(cx, cy, radius, 0, Math.PI * 2)
    ctx.stroke()

    // Progress arc
    ctx.strokeStyle = progressColor
    ctx.beginPath()
    ctx.arc(cx, cy, radius, startAngle, endAngle)
    ctx.stroke()
  } else {
    // Linear progress
    ctx.fillStyle = progressBackgroundColor
    ctx.fillRect(x, y, width, height)

    ctx.fillStyle = progressColor
    ctx.fillRect(x, y, width * pct, height)
  }
}

function drawGrid(ctx: CanvasRenderingContext2D) {
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)'
  ctx.lineWidth = 1

  const gridSize = 20

  for (let x = 0; x <= WATCH_WIDTH; x += gridSize) {
    ctx.beginPath()
    ctx.moveTo(x, 0)
    ctx.lineTo(x, WATCH_HEIGHT)
    ctx.stroke()
  }

  for (let y = 0; y <= WATCH_HEIGHT; y += gridSize) {
    ctx.beginPath()
    ctx.moveTo(0, y)
    ctx.lineTo(WATCH_WIDTH, y)
    ctx.stroke()
  }

  // Center lines
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)'
  ctx.beginPath()
  ctx.moveTo(WATCH_WIDTH / 2, 0)
  ctx.lineTo(WATCH_WIDTH / 2, WATCH_HEIGHT)
  ctx.stroke()
  ctx.beginPath()
  ctx.moveTo(0, WATCH_HEIGHT / 2)
  ctx.lineTo(WATCH_WIDTH, WATCH_HEIGHT / 2)
  ctx.stroke()
}

function drawSelectionBox(ctx: CanvasRenderingContext2D, element: WatchElement) {
  const { x, y, width, height } = element.properties

  ctx.strokeStyle = '#6366F1'
  ctx.lineWidth = 2
  ctx.setLineDash([5, 5])
  ctx.strokeRect(x - 2, y - 2, width + 4, height + 4)
  ctx.setLineDash([])

  // Corner handles
  const handleSize = 8
  ctx.fillStyle = '#6366F1'
  const corners = [
    [x - handleSize / 2, y - handleSize / 2],
    [x + width - handleSize / 2, y - handleSize / 2],
    [x - handleSize / 2, y + height - handleSize / 2],
    [x + width - handleSize / 2, y + height - handleSize / 2],
  ]

  for (const [cx, cy] of corners) {
    ctx.fillRect(cx, cy, handleSize, handleSize)
  }
}

function roundRect(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  width: number,
  height: number,
  radius: number
) {
  ctx.beginPath()
  ctx.moveTo(x + radius, y)
  ctx.lineTo(x + width - radius, y)
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
  ctx.lineTo(x + width, y + height - radius)
  ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
  ctx.lineTo(x + radius, y + height)
  ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
  ctx.lineTo(x, y + radius)
  ctx.quadraticCurveTo(x, y, x + radius, y)
  ctx.closePath()
}

function getFontString(font: string): string {
  switch (font) {
    case 'system-hot':
      return 'bold 72px system-ui'
    case 'system-medium':
      return 'bold 48px system-ui'
    case 'system-small':
      return '24px system-ui'
    case 'system-tiny':
      return '16px system-ui'
    case 'pixel':
      return '16px monospace'
    default:
      return '24px system-ui'
  }
}
