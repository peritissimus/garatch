import { useEffect, useCallback, useRef } from 'react'
import { useDesignerStore } from '@/store'
import type { WatchElement } from '@/store/types'

export function useKeyboardShortcuts() {
  const clipboardRef = useRef<WatchElement[]>([])

  const {
    selectedElementIds,
    project,
    removeElement,
    duplicateElement,
    updateElement,
    undo,
    redo,
    addElement,
    selectElements,
    snapToGrid,
    gridSize,
  } = useDesignerStore()

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      // Don't handle shortcuts when typing in inputs
      if (
        e.target instanceof HTMLInputElement ||
        e.target instanceof HTMLTextAreaElement
      ) {
        return
      }

      const isMeta = e.metaKey || e.ctrlKey
      const isShift = e.shiftKey

      // Delete selected elements
      if (e.key === 'Delete' || e.key === 'Backspace') {
        if (selectedElementIds.length > 0) {
          e.preventDefault()
          for (const id of selectedElementIds) {
            removeElement(id)
          }
        }
        return
      }

      // Undo: Ctrl+Z
      if (isMeta && e.key === 'z' && !isShift) {
        e.preventDefault()
        undo()
        return
      }

      // Redo: Ctrl+Shift+Z or Ctrl+Y
      if ((isMeta && e.key === 'z' && isShift) || (isMeta && e.key === 'y')) {
        e.preventDefault()
        redo()
        return
      }

      // Duplicate: Ctrl+D
      if (isMeta && e.key === 'd') {
        if (selectedElementIds.length > 0) {
          e.preventDefault()
          for (const id of selectedElementIds) {
            duplicateElement(id)
          }
        }
        return
      }

      // Copy: Ctrl+C
      if (isMeta && e.key === 'c') {
        if (selectedElementIds.length > 0 && project) {
          e.preventDefault()
          clipboardRef.current = project.elements.filter((el) =>
            selectedElementIds.includes(el.id)
          )
        }
        return
      }

      // Paste: Ctrl+V
      if (isMeta && e.key === 'v') {
        if (clipboardRef.current.length > 0) {
          e.preventDefault()
          const newIds: string[] = []
          for (const element of clipboardRef.current) {
            const newId = crypto.randomUUID()
            const newElement: WatchElement = {
              ...element,
              id: newId,
              properties: {
                ...element.properties,
                id: newId,
                name: `${element.properties.name} (copy)`,
                x: element.properties.x + 20,
                y: element.properties.y + 20,
              },
            }
            addElement(newElement)
            newIds.push(newId)
          }
          selectElements(newIds)
        }
        return
      }

      // Select All: Ctrl+A
      if (isMeta && e.key === 'a') {
        if (project) {
          e.preventDefault()
          selectElements(project.elements.map((el) => el.id))
        }
        return
      }

      // Arrow keys: nudge selected elements
      const arrowKeys = ['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight']
      if (arrowKeys.includes(e.key) && selectedElementIds.length > 0) {
        e.preventDefault()
        const step = isShift ? (snapToGrid ? gridSize : 10) : 1

        for (const id of selectedElementIds) {
          const element = project?.elements.find((el) => el.id === id)
          if (!element || element.properties.locked) continue

          let { x, y } = element.properties

          switch (e.key) {
            case 'ArrowUp':
              y = Math.max(0, y - step)
              break
            case 'ArrowDown':
              y = y + step
              break
            case 'ArrowLeft':
              x = Math.max(0, x - step)
              break
            case 'ArrowRight':
              x = x + step
              break
          }

          updateElement(id, { x, y })
        }
        return
      }

      // Escape: deselect all
      if (e.key === 'Escape') {
        selectElements([])
        return
      }
    },
    [
      selectedElementIds,
      project,
      removeElement,
      duplicateElement,
      updateElement,
      undo,
      redo,
      addElement,
      selectElements,
      snapToGrid,
      gridSize,
    ]
  )

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [handleKeyDown])
}
