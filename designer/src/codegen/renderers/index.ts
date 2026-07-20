/**
 * Element renderers - convert design elements to MonkeyC drawing code
 */

import type { WatchElement } from '@/store/types'
import { hexToMonkeyC, getBatteryColorCode } from '../utils/color-converter'
import { fontToMonkeyC, getCenteredJustification, requiresPixelFont } from '../utils/font-mapper'

/**
 * Generate MonkeyC drawing code for an element
 */
export function renderElement(element: WatchElement, index: number): string {
  const { type, properties: props } = element
  const funcName = `drawElement${index}`

  switch (type) {
    case 'background':
      return renderBackground(props)
    case 'time-digital':
      return renderTimeDigital(props, funcName)
    case 'time-analog':
      return renderTimeAnalog(props, funcName)
    case 'date':
      return renderDate(props, funcName)
    case 'battery':
      return renderBattery(props, funcName)
    case 'steps':
      return renderSteps(props, funcName)
    case 'heart-rate':
      return renderHeartRate(props, funcName)
    case 'shape':
      return renderShape(props, funcName)
    case 'text':
      return renderText(props, funcName)
    case 'progress-bar':
      return renderProgressBar(props, funcName)
    default:
      return `// Unknown element type: ${type}`
  }
}

/**
 * Generate the onUpdate call for an element
 */
export function renderElementCall(element: WatchElement, index: number): string {
  const { type } = element

  if (type === 'background') {
    // Background is drawn inline, not as a function call
    return ''
  }

  return `        drawElement${index}(dc);`
}

function renderBackground(props: WatchElement['properties']): string {
  const bgColor = hexToMonkeyC(props.backgroundColor)
  return `        // Background
        dc.setColor(${bgColor}, ${bgColor});
        dc.clear();`
}

function renderTimeDigital(props: WatchElement['properties'], funcName: string): string {
  const { x, y, width, height, color, font, format24h, showSeconds } = props
  const colorCode = hexToMonkeyC(color)
  const fontCode = fontToMonkeyC(font)
  const cx = x! + width! / 2
  const cy = y! + height! / 2

  const usePixelFont = requiresPixelFont(font)

  if (usePixelFont) {
    return `
    function ${funcName}(dc) {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour${!format24h ? ' % 12' : ''};
        ${!format24h ? 'if (hour == 0) { hour = 12; }' : ''}
        var timeStr = hour.format("%02d") + ":" + clockTime.min.format("%02d")${showSeconds ? ' + ":" + clockTime.sec.format("%02d")' : ''};

        dc.setColor(${colorCode}, Graphics.COLOR_TRANSPARENT);
        PixelFont.drawLabelScaled(dc, ${Math.round(cx)}, ${Math.round(cy)}, timeStr, 4);
    }`
  }

  return `
    function ${funcName}(dc) {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour${!format24h ? ' % 12' : ''};
        ${!format24h ? 'if (hour == 0) { hour = 12; }' : ''}
        var timeStr = hour.format("%02d") + ":" + clockTime.min.format("%02d")${showSeconds ? ' + ":" + clockTime.sec.format("%02d")' : ''};

        dc.setColor(${colorCode}, Graphics.COLOR_TRANSPARENT);
        dc.drawText(${Math.round(cx)}, ${Math.round(cy)}, ${fontCode}, timeStr, ${getCenteredJustification()});
    }`
}

function renderTimeAnalog(props: WatchElement['properties'], funcName: string): string {
  const {
    x, y, width, height,
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

  const cx = Math.round(x! + width! / 2)
  const cy = Math.round(y! + height! / 2)

  return `
    function ${funcName}(dc) {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour % 12;
        var minute = clockTime.min;
        var second = clockTime.sec;

        // Hour hand
        var hourAngle = Math.toRadians(((hour * 60) + minute) * 0.5 - 90);
        drawHand(dc, ${cx}, ${cy}, hourAngle, ${hourHandLength}, ${hourHandWidth}, ${hexToMonkeyC(hourHandColor)});

        // Minute hand
        var minAngle = Math.toRadians(minute * 6 - 90);
        drawHand(dc, ${cx}, ${cy}, minAngle, ${minuteHandLength}, ${minuteHandWidth}, ${hexToMonkeyC(minuteHandColor)});
        ${showSecondHand ? `
        // Second hand
        var secAngle = Math.toRadians(second * 6 - 90);
        drawHand(dc, ${cx}, ${cy}, secAngle, ${secondHandLength}, ${secondHandWidth}, ${hexToMonkeyC(secondHandColor)});` : ''}

        // Center dot
        dc.setColor(${hexToMonkeyC(centerDotColor)}, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(${cx}, ${cy}, ${centerDotRadius});
    }

    function drawHand(dc, cx, cy, angle, length, width, color) {
        var endX = cx + length * Math.cos(angle);
        var endY = cy + length * Math.sin(angle);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(width);
        dc.drawLine(cx, cy, endX, endY);
    }`
}

function renderDate(props: WatchElement['properties'], funcName: string): string {
  const { x, y, width, height, color, font } = props
  const colorCode = hexToMonkeyC(color)
  const fontCode = fontToMonkeyC(font)
  const cx = Math.round(x! + width! / 2)
  const cy = Math.round(y! + height! / 2)

  return `
    function ${funcName}(dc) {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        var dateStr = dayNames[info.day_of_week] + " " + info.day;

        dc.setColor(${colorCode}, Graphics.COLOR_TRANSPARENT);
        dc.drawText(${cx}, ${cy}, ${fontCode}, dateStr, ${getCenteredJustification()});
    }`
}

function renderBattery(props: WatchElement['properties'], funcName: string): string {
  const { x, y, width, height, color } = props
  const colorCode = hexToMonkeyC(color)

  return `
    function ${funcName}(dc) {
        var stats = System.getSystemStats();
        var battery = stats.battery.toNumber();

        // Battery outline
        dc.setColor(${colorCode}, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(${x}, ${y}, ${width! - 4}, ${height});

        // Battery cap
        dc.fillRectangle(${x! + width! - 4}, ${y! + height! / 4}, 4, ${height! / 2});

        // Battery fill with color based on level
        ${getBatteryColorCode('battery')}
        dc.setColor(batColor, Graphics.COLOR_TRANSPARENT);
        var fillWidth = ((${width! - 8}) * battery) / 100;
        dc.fillRectangle(${x! + 2}, ${y! + 2}, fillWidth, ${height! - 4});
    }`
}

function renderSteps(props: WatchElement['properties'], funcName: string): string {
  const { x, y, width, height, color, font } = props
  const colorCode = hexToMonkeyC(color)
  const fontCode = fontToMonkeyC(font)
  const cx = Math.round(x! + width! / 2)
  const cy = Math.round(y! + height! / 2)

  return `
    function ${funcName}(dc) {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;

        dc.setColor(${colorCode}, Graphics.COLOR_TRANSPARENT);
        dc.drawText(${cx}, ${cy}, ${fontCode}, steps.format("%d"), ${getCenteredJustification()});
    }`
}

function renderHeartRate(props: WatchElement['properties'], funcName: string): string {
  const { x, y, width, height, color, font } = props
  const colorCode = hexToMonkeyC(color)
  const fontCode = fontToMonkeyC(font)
  const cx = Math.round(x! + width! / 2)
  const cy = Math.round(y! + height! / 2)

  return `
    function ${funcName}(dc) {
        var actInfo = Activity.getActivityInfo();
        var hr = actInfo.currentHeartRate;
        if (hr == null) { hr = 0; }

        dc.setColor(${colorCode}, Graphics.COLOR_TRANSPARENT);
        dc.drawText(${cx}, ${cy}, ${fontCode}, hr.format("%d"), ${getCenteredJustification()});
    }`
}

function renderShape(props: WatchElement['properties'], funcName: string): string {
  const {
    x, y, width, height,
    shapeType,
    strokeWidth = 2,
    strokeColor,
    fillColor,
    cornerRadius = 0,
  } = props

  const strokeCode = hexToMonkeyC(strokeColor)
  const fillCode = hexToMonkeyC(fillColor)
  const hasFill = fillColor && fillColor !== 'transparent'
  const hasStroke = strokeColor && strokeColor !== 'transparent'

  switch (shapeType) {
    case 'circle': {
      const cx = Math.round(x! + width! / 2)
      const cy = Math.round(y! + height! / 2)
      const rx = Math.round(width! / 2)
      const ry = Math.round(height! / 2)
      // For ellipse, use the smaller radius for circle approximation
      const r = Math.min(rx, ry)

      return `
    function ${funcName}(dc) {
        ${hasFill ? `dc.setColor(${fillCode}, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(${cx}, ${cy}, ${r});` : ''}
        ${hasStroke ? `dc.setColor(${strokeCode}, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(${strokeWidth});
        dc.drawCircle(${cx}, ${cy}, ${r});` : ''}
    }`
    }

    case 'line':
      return `
    function ${funcName}(dc) {
        dc.setColor(${strokeCode}, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(${strokeWidth});
        dc.drawLine(${x}, ${y}, ${x! + width!}, ${y! + height!});
    }`

    case 'rectangle':
    default:
      if (cornerRadius && cornerRadius > 0) {
        return `
    function ${funcName}(dc) {
        ${hasFill ? `dc.setColor(${fillCode}, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(${x}, ${y}, ${width}, ${height}, ${cornerRadius});` : ''}
        ${hasStroke ? `dc.setColor(${strokeCode}, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(${strokeWidth});
        dc.drawRoundedRectangle(${x}, ${y}, ${width}, ${height}, ${cornerRadius});` : ''}
    }`
      }

      return `
    function ${funcName}(dc) {
        ${hasFill ? `dc.setColor(${fillCode}, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(${x}, ${y}, ${width}, ${height});` : ''}
        ${hasStroke ? `dc.setColor(${strokeCode}, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(${strokeWidth});
        dc.drawRectangle(${x}, ${y}, ${width}, ${height});` : ''}
    }`
  }
}

function renderText(props: WatchElement['properties'], funcName: string): string {
  const { x, y, width, height, color, font, text, textAlign } = props
  const colorCode = hexToMonkeyC(color)
  const fontCode = fontToMonkeyC(font)

  let textX = x!
  let justification = 'Graphics.TEXT_JUSTIFY_LEFT'

  if (textAlign === 'center') {
    textX = x! + width! / 2
    justification = 'Graphics.TEXT_JUSTIFY_CENTER'
  } else if (textAlign === 'right') {
    textX = x! + width!
    justification = 'Graphics.TEXT_JUSTIFY_RIGHT'
  }

  const cy = Math.round(y! + height! / 2)

  return `
    function ${funcName}(dc) {
        dc.setColor(${colorCode}, Graphics.COLOR_TRANSPARENT);
        dc.drawText(${Math.round(textX)}, ${cy}, ${fontCode}, "${text || ''}", ${justification} | Graphics.TEXT_JUSTIFY_VCENTER);
    }`
}

function renderProgressBar(props: WatchElement['properties'], funcName: string): string {
  const {
    x, y, width, height,
    progressType,
    progressValue = 50,
    progressMax = 100,
    progressColor,
    progressBackgroundColor,
  } = props

  const fgColor = hexToMonkeyC(progressColor)
  const bgColor = hexToMonkeyC(progressBackgroundColor)

  if (progressType === 'arc') {
    const cx = Math.round(x! + width! / 2)
    const cy = Math.round(y! + height! / 2)
    const radius = Math.round(Math.min(width!, height!) / 2 - 4)

    return `
    function ${funcName}(dc) {
        // For dynamic progress, replace with actual data source
        var pct = ${progressValue}.toFloat() / ${progressMax}.toFloat();
        if (pct > 1.0) { pct = 1.0; }

        var startAngle = 90;
        var sweepAngle = (360 * pct).toNumber();

        // Background arc
        dc.setColor(${bgColor}, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(8);
        dc.drawArc(${cx}, ${cy}, ${radius}, Graphics.ARC_CLOCKWISE, 90, 90);

        // Progress arc
        dc.setColor(${fgColor}, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(${cx}, ${cy}, ${radius}, Graphics.ARC_CLOCKWISE, startAngle, startAngle - sweepAngle);
    }`
  }

  // Linear progress bar
  return `
    function ${funcName}(dc) {
        // For dynamic progress, replace with actual data source
        var pct = ${progressValue}.toFloat() / ${progressMax}.toFloat();
        if (pct > 1.0) { pct = 1.0; }

        // Background
        dc.setColor(${bgColor}, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(${x}, ${y}, ${width}, ${height});

        // Progress fill
        dc.setColor(${fgColor}, Graphics.COLOR_TRANSPARENT);
        var fillWidth = (${width} * pct).toNumber();
        dc.fillRectangle(${x}, ${y}, fillWidth, ${height});
    }`
}

/**
 * Check if any element uses the PixelFont module
 */
export function requiresPixelFontModule(elements: WatchElement[]): boolean {
  return elements.some((el) => requiresPixelFont(el.properties.font))
}
