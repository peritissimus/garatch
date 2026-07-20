import {
  AlignLeft,
  AlignCenter,
  AlignRight,
  AlignStartVertical,
  AlignCenterVertical,
  AlignEndVertical,
  MoveHorizontal,
  MoveVertical,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import { useDesignerStore } from '@/store'

export function AlignmentToolbar() {
  const { selectedElementIds, alignElements, distributeElements } = useDesignerStore()

  const hasSelection = selectedElementIds.length > 0
  const canDistribute = selectedElementIds.length >= 3

  if (!hasSelection) return null

  return (
    <div className="p-3 border-b border-border">
      <div className="text-xs font-medium text-muted-foreground mb-2">Align</div>
      <div className="flex gap-1 flex-wrap">
        {/* Horizontal alignment */}
        <Button
          variant="ghost"
          size="icon"
          className="h-7 w-7"
          title="Align Left"
          onClick={() => alignElements('left')}
        >
          <AlignLeft className="h-3.5 w-3.5" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          className="h-7 w-7"
          title="Align Center Horizontally"
          onClick={() => alignElements('center-h')}
        >
          <AlignCenter className="h-3.5 w-3.5" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          className="h-7 w-7"
          title="Align Right"
          onClick={() => alignElements('right')}
        >
          <AlignRight className="h-3.5 w-3.5" />
        </Button>

        <Separator orientation="vertical" className="h-6 mx-1" />

        {/* Vertical alignment */}
        <Button
          variant="ghost"
          size="icon"
          className="h-7 w-7"
          title="Align Top"
          onClick={() => alignElements('top')}
        >
          <AlignStartVertical className="h-3.5 w-3.5" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          className="h-7 w-7"
          title="Align Center Vertically"
          onClick={() => alignElements('center-v')}
        >
          <AlignCenterVertical className="h-3.5 w-3.5" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          className="h-7 w-7"
          title="Align Bottom"
          onClick={() => alignElements('bottom')}
        >
          <AlignEndVertical className="h-3.5 w-3.5" />
        </Button>

        {canDistribute && (
          <>
            <Separator orientation="vertical" className="h-6 mx-1" />

            {/* Distribution */}
            <Button
              variant="ghost"
              size="icon"
              className="h-7 w-7"
              title="Distribute Horizontally"
              onClick={() => distributeElements('horizontal')}
            >
              <MoveHorizontal className="h-3.5 w-3.5" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              className="h-7 w-7"
              title="Distribute Vertically"
              onClick={() => distributeElements('vertical')}
            >
              <MoveVertical className="h-3.5 w-3.5" />
            </Button>
          </>
        )}
      </div>
    </div>
  )
}
