import { useDesignerStore } from '@/store'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Slider } from '@/components/ui/slider'
import { ScrollArea } from '@/components/ui/scroll-area'
import { Separator } from '@/components/ui/separator'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { AlignmentToolbar } from '@/components/toolbar/AlignmentToolbar'
import { FONT_OPTIONS } from '@/lib/constants'
import type { ElementProperties, FontType, ShapeType } from '@/store/types'

export function PropertiesPanel() {
  const { project, selectedElementIds, updateElement } = useDesignerStore()

  const selectedElement =
    selectedElementIds.length === 1
      ? project?.elements.find((el) => el.id === selectedElementIds[0])
      : null

  const handleChange = (key: keyof ElementProperties, value: unknown) => {
    if (!selectedElement) return
    updateElement(selectedElement.id, { [key]: value })
  }

  if (!selectedElement) {
    return (
      <div className="flex-1 border-b border-border">
        <div className="px-4 py-3 border-b border-border">
          <h3 className="text-sm font-medium">Properties</h3>
        </div>
        <AlignmentToolbar />
        <div className="p-4 text-sm text-muted-foreground">
          Select an element to edit its properties
        </div>
      </div>
    )
  }

  const props = selectedElement.properties

  return (
    <div className="flex-1 border-b border-border flex flex-col overflow-hidden">
      <div className="px-4 py-3 border-b border-border">
        <h3 className="text-sm font-medium">Properties</h3>
        <p className="text-xs text-muted-foreground">{props.name}</p>
      </div>
      <AlignmentToolbar />

      <ScrollArea className="flex-1">
        <div className="p-4 space-y-6">
          {/* Position */}
          <div className="space-y-3">
            <h4 className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
              Position
            </h4>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label className="text-xs">X</Label>
                <Input
                  type="number"
                  value={props.x}
                  onChange={(e) => handleChange('x', Number(e.target.value))}
                  className="h-8"
                />
              </div>
              <div className="space-y-1">
                <Label className="text-xs">Y</Label>
                <Input
                  type="number"
                  value={props.y}
                  onChange={(e) => handleChange('y', Number(e.target.value))}
                  className="h-8"
                />
              </div>
            </div>
          </div>

          {/* Size */}
          <div className="space-y-3">
            <h4 className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
              Size
            </h4>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label className="text-xs">Width</Label>
                <Input
                  type="number"
                  value={props.width}
                  onChange={(e) => handleChange('width', Number(e.target.value))}
                  className="h-8"
                />
              </div>
              <div className="space-y-1">
                <Label className="text-xs">Height</Label>
                <Input
                  type="number"
                  value={props.height}
                  onChange={(e) => handleChange('height', Number(e.target.value))}
                  className="h-8"
                />
              </div>
            </div>
          </div>

          <Separator />

          {/* Color */}
          <div className="space-y-3">
            <h4 className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
              Appearance
            </h4>
            <div className="space-y-3">
              <div className="space-y-1">
                <Label className="text-xs">Color</Label>
                <div className="flex gap-2">
                  <Input
                    type="color"
                    value={props.color || '#FFFFFF'}
                    onChange={(e) => handleChange('color', e.target.value)}
                    className="h-8 w-12 p-1 cursor-pointer"
                  />
                  <Input
                    type="text"
                    value={props.color || '#FFFFFF'}
                    onChange={(e) => handleChange('color', e.target.value)}
                    className="h-8 flex-1 font-mono text-xs"
                  />
                </div>
              </div>

              {(selectedElement.type === 'shape' ||
                selectedElement.type === 'background') && (
                <div className="space-y-1">
                  <Label className="text-xs">Background Color</Label>
                  <div className="flex gap-2">
                    <Input
                      type="color"
                      value={props.backgroundColor || '#000000'}
                      onChange={(e) => handleChange('backgroundColor', e.target.value)}
                      className="h-8 w-12 p-1 cursor-pointer"
                    />
                    <Input
                      type="text"
                      value={props.backgroundColor || '#000000'}
                      onChange={(e) => handleChange('backgroundColor', e.target.value)}
                      className="h-8 flex-1 font-mono text-xs"
                    />
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Font settings for text elements */}
          {(selectedElement.type === 'time-digital' ||
            selectedElement.type === 'date' ||
            selectedElement.type === 'text' ||
            selectedElement.type === 'steps' ||
            selectedElement.type === 'heart-rate') && (
            <>
              <Separator />
              <div className="space-y-3">
                <h4 className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
                  Typography
                </h4>
                <div className="space-y-1">
                  <Label className="text-xs">Font</Label>
                  <Select
                    value={props.font || 'system-small'}
                    onValueChange={(value) => handleChange('font', value as FontType)}
                  >
                    <SelectTrigger className="h-8">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {FONT_OPTIONS.map((font) => (
                        <SelectItem key={font.value} value={font.value}>
                          {font.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </>
          )}

          {/* Text content */}
          {selectedElement.type === 'text' && (
            <div className="space-y-1">
              <Label className="text-xs">Text</Label>
              <Input
                type="text"
                value={props.text || ''}
                onChange={(e) => handleChange('text', e.target.value)}
                className="h-8"
              />
            </div>
          )}

          {/* Time-specific settings */}
          {selectedElement.type === 'time-digital' && (
            <>
              <Separator />
              <div className="space-y-3">
                <h4 className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
                  Time Format
                </h4>
                <div className="space-y-2">
                  <label className="flex items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      checked={props.format24h}
                      onChange={(e) => handleChange('format24h', e.target.checked)}
                      className="rounded"
                    />
                    24-hour format
                  </label>
                  <label className="flex items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      checked={props.showSeconds}
                      onChange={(e) => handleChange('showSeconds', e.target.checked)}
                      className="rounded"
                    />
                    Show seconds
                  </label>
                </div>
              </div>
            </>
          )}

          {/* Analog clock settings */}
          {selectedElement.type === 'time-analog' && (
            <>
              <Separator />
              <div className="space-y-3">
                <h4 className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
                  Clock Hands
                </h4>

                <div className="space-y-1">
                  <Label className="text-xs">Hour Hand Length</Label>
                  <Slider
                    value={[props.hourHandLength || 50]}
                    min={20}
                    max={100}
                    step={1}
                    onValueChange={(value) =>
                      handleChange('hourHandLength', typeof value === 'number' ? value : value[0])
                    }
                  />
                </div>

                <div className="space-y-1">
                  <Label className="text-xs">Minute Hand Length</Label>
                  <Slider
                    value={[props.minuteHandLength || 75]}
                    min={20}
                    max={120}
                    step={1}
                    onValueChange={(value) =>
                      handleChange('minuteHandLength', typeof value === 'number' ? value : value[0])
                    }
                  />
                </div>

                <label className="flex items-center gap-2 text-sm">
                  <input
                    type="checkbox"
                    checked={props.showSecondHand}
                    onChange={(e) => handleChange('showSecondHand', e.target.checked)}
                    className="rounded"
                  />
                  Show second hand
                </label>

                <div className="space-y-1">
                  <Label className="text-xs">Hour Hand Color</Label>
                  <div className="flex gap-2">
                    <Input
                      type="color"
                      value={props.hourHandColor || '#FFFFFF'}
                      onChange={(e) => handleChange('hourHandColor', e.target.value)}
                      className="h-8 w-12 p-1"
                    />
                    <Input
                      type="text"
                      value={props.hourHandColor || '#FFFFFF'}
                      onChange={(e) => handleChange('hourHandColor', e.target.value)}
                      className="h-8 flex-1 font-mono text-xs"
                    />
                  </div>
                </div>

                <div className="space-y-1">
                  <Label className="text-xs">Second Hand Color</Label>
                  <div className="flex gap-2">
                    <Input
                      type="color"
                      value={props.secondHandColor || '#FF6600'}
                      onChange={(e) => handleChange('secondHandColor', e.target.value)}
                      className="h-8 w-12 p-1"
                    />
                    <Input
                      type="text"
                      value={props.secondHandColor || '#FF6600'}
                      onChange={(e) => handleChange('secondHandColor', e.target.value)}
                      className="h-8 flex-1 font-mono text-xs"
                    />
                  </div>
                </div>
              </div>
            </>
          )}

          {/* Shape settings */}
          {selectedElement.type === 'shape' && (
            <>
              <Separator />
              <div className="space-y-3">
                <h4 className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
                  Shape
                </h4>
                <div className="space-y-1">
                  <Label className="text-xs">Type</Label>
                  <Select
                    value={props.shapeType || 'rectangle'}
                    onValueChange={(value) => handleChange('shapeType', value as ShapeType)}
                  >
                    <SelectTrigger className="h-8">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="rectangle">Rectangle</SelectItem>
                      <SelectItem value="circle">Circle/Ellipse</SelectItem>
                      <SelectItem value="line">Line</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-1">
                  <Label className="text-xs">Stroke Width</Label>
                  <Slider
                    value={[props.strokeWidth || 2]}
                    min={0}
                    max={20}
                    step={1}
                    onValueChange={(value) =>
                      handleChange('strokeWidth', typeof value === 'number' ? value : value[0])
                    }
                  />
                </div>

                <div className="space-y-1">
                  <Label className="text-xs">Stroke Color</Label>
                  <div className="flex gap-2">
                    <Input
                      type="color"
                      value={props.strokeColor || '#FFFFFF'}
                      onChange={(e) => handleChange('strokeColor', e.target.value)}
                      className="h-8 w-12 p-1"
                    />
                    <Input
                      type="text"
                      value={props.strokeColor || '#FFFFFF'}
                      onChange={(e) => handleChange('strokeColor', e.target.value)}
                      className="h-8 flex-1 font-mono text-xs"
                    />
                  </div>
                </div>

                <div className="space-y-1">
                  <Label className="text-xs">Fill Color</Label>
                  <div className="flex gap-2">
                    <Input
                      type="color"
                      value={props.fillColor || '#000000'}
                      onChange={(e) => handleChange('fillColor', e.target.value)}
                      className="h-8 w-12 p-1"
                    />
                    <Input
                      type="text"
                      value={props.fillColor || 'transparent'}
                      onChange={(e) => handleChange('fillColor', e.target.value)}
                      className="h-8 flex-1 font-mono text-xs"
                      placeholder="transparent"
                    />
                  </div>
                </div>

                {props.shapeType === 'rectangle' && (
                  <div className="space-y-1">
                    <Label className="text-xs">Corner Radius</Label>
                    <Slider
                      value={[props.cornerRadius || 0]}
                      min={0}
                      max={50}
                      step={1}
                      onValueChange={(value) =>
                        handleChange('cornerRadius', typeof value === 'number' ? value : value[0])
                      }
                    />
                  </div>
                )}
              </div>
            </>
          )}

          {/* Progress bar settings */}
          {selectedElement.type === 'progress-bar' && (
            <>
              <Separator />
              <div className="space-y-3">
                <h4 className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
                  Progress
                </h4>
                <div className="space-y-1">
                  <Label className="text-xs">Type</Label>
                  <Select
                    value={props.progressType || 'linear'}
                    onValueChange={(value) =>
                      handleChange('progressType', value as 'linear' | 'arc')
                    }
                  >
                    <SelectTrigger className="h-8">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="linear">Linear</SelectItem>
                      <SelectItem value="arc">Arc</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-1">
                  <Label className="text-xs">Value ({props.progressValue || 50}%)</Label>
                  <Slider
                    value={[props.progressValue || 50]}
                    min={0}
                    max={100}
                    step={1}
                    onValueChange={(value) =>
                      handleChange('progressValue', typeof value === 'number' ? value : value[0])
                    }
                  />
                </div>

                <div className="space-y-1">
                  <Label className="text-xs">Progress Color</Label>
                  <div className="flex gap-2">
                    <Input
                      type="color"
                      value={props.progressColor || '#FFFFFF'}
                      onChange={(e) => handleChange('progressColor', e.target.value)}
                      className="h-8 w-12 p-1"
                    />
                    <Input
                      type="text"
                      value={props.progressColor || '#FFFFFF'}
                      onChange={(e) => handleChange('progressColor', e.target.value)}
                      className="h-8 flex-1 font-mono text-xs"
                    />
                  </div>
                </div>
              </div>
            </>
          )}
        </div>
      </ScrollArea>
    </div>
  )
}
