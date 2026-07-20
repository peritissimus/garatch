import {
  Eye,
  EyeOff,
  Lock,
  Unlock,
  Trash2,
  Copy,
  ChevronUp,
  ChevronDown,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'
import { useDesignerStore } from '@/store'
import { cn } from '@/lib/utils'

export function LayersPanel() {
  const {
    project,
    selectedElementIds,
    selectElements,
    toggleElementVisibility,
    toggleElementLock,
    removeElement,
    duplicateElement,
    reorderElements,
  } = useDesignerStore()

  const elements = project?.elements || []

  // Sort by zIndex descending (top layers first)
  const sortedElements = [...elements].sort(
    (a, b) => b.properties.zIndex - a.properties.zIndex
  )

  const handleMoveUp = (id: string) => {
    const currentIndex = elements.findIndex((el) => el.id === id)
    if (currentIndex < elements.length - 1) {
      reorderElements(currentIndex, currentIndex + 1)
    }
  }

  const handleMoveDown = (id: string) => {
    const currentIndex = elements.findIndex((el) => el.id === id)
    if (currentIndex > 0) {
      reorderElements(currentIndex, currentIndex - 1)
    }
  }

  return (
    <div className="h-64 flex flex-col">
      <div className="px-4 py-3 border-b border-border flex items-center justify-between">
        <h3 className="text-sm font-medium">Layers</h3>
        <span className="text-xs text-muted-foreground">{elements.length} items</span>
      </div>

      <ScrollArea className="flex-1">
        <div className="p-2">
          {sortedElements.length === 0 ? (
            <p className="text-sm text-muted-foreground p-2">
              No elements yet. Add elements from the palette.
            </p>
          ) : (
            <div className="space-y-1">
              {sortedElements.map((element) => {
                const isSelected = selectedElementIds.includes(element.id)
                const { visible, locked, name } = element.properties

                return (
                  <div
                    key={element.id}
                    className={cn(
                      'flex items-center gap-2 px-2 py-1.5 rounded-md cursor-pointer transition-colors group',
                      isSelected
                        ? 'bg-accent text-accent-foreground'
                        : 'hover:bg-accent/50'
                    )}
                    onClick={() => selectElements([element.id])}
                  >
                    {/* Visibility toggle */}
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-6 w-6 opacity-60 hover:opacity-100"
                      onClick={(e) => {
                        e.stopPropagation()
                        toggleElementVisibility(element.id)
                      }}
                      title={visible ? 'Hide' : 'Show'}
                    >
                      {visible ? (
                        <Eye className="h-3.5 w-3.5" />
                      ) : (
                        <EyeOff className="h-3.5 w-3.5" />
                      )}
                    </Button>

                    {/* Lock toggle */}
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-6 w-6 opacity-60 hover:opacity-100"
                      onClick={(e) => {
                        e.stopPropagation()
                        toggleElementLock(element.id)
                      }}
                      title={locked ? 'Unlock' : 'Lock'}
                    >
                      {locked ? (
                        <Lock className="h-3.5 w-3.5" />
                      ) : (
                        <Unlock className="h-3.5 w-3.5" />
                      )}
                    </Button>

                    {/* Element name */}
                    <span
                      className={cn(
                        'flex-1 text-sm truncate',
                        !visible && 'opacity-50'
                      )}
                    >
                      {name}
                    </span>

                    {/* Actions (visible on hover or selection) */}
                    <div
                      className={cn(
                        'flex items-center gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity',
                        isSelected && 'opacity-100'
                      )}
                    >
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6"
                        onClick={(e) => {
                          e.stopPropagation()
                          handleMoveUp(element.id)
                        }}
                        title="Move Up"
                      >
                        <ChevronUp className="h-3.5 w-3.5" />
                      </Button>

                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6"
                        onClick={(e) => {
                          e.stopPropagation()
                          handleMoveDown(element.id)
                        }}
                        title="Move Down"
                      >
                        <ChevronDown className="h-3.5 w-3.5" />
                      </Button>

                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6"
                        onClick={(e) => {
                          e.stopPropagation()
                          duplicateElement(element.id)
                        }}
                        title="Duplicate"
                      >
                        <Copy className="h-3.5 w-3.5" />
                      </Button>

                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6 text-destructive hover:text-destructive"
                        onClick={(e) => {
                          e.stopPropagation()
                          removeElement(element.id)
                        }}
                        title="Delete"
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </Button>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      </ScrollArea>
    </div>
  )
}
