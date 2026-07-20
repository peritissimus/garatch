import { useEffect } from 'react'
import { Toolbar } from '@/components/toolbar/Toolbar'
import { ElementPalette } from '@/components/toolbar/ElementPalette'
import { WatchCanvas } from '@/components/canvas/WatchCanvas'
import { PropertiesPanel } from '@/components/panels/PropertiesPanel'
import { LayersPanel } from '@/components/panels/LayersPanel'
import { useDesignerStore } from '@/store'
import { useKeyboardShortcuts } from '@/hooks/useKeyboardShortcuts'

export default function App() {
  const { project, newProject } = useDesignerStore()

  // Enable keyboard shortcuts
  useKeyboardShortcuts()

  // Create a default project on first load
  useEffect(() => {
    if (!project) {
      newProject('Untitled Watch Face')
    }
  }, [project, newProject])

  return (
    <div className="flex h-screen flex-col bg-background text-foreground overflow-hidden">
      {/* Title bar drag region */}
      <div className="h-8 titlebar-drag bg-card border-b border-border flex items-center px-20">
        <span className="text-xs text-muted-foreground font-medium">
          Garatch Designer
        </span>
      </div>

      {/* Toolbar */}
      <Toolbar />

      {/* Main content area */}
      <div className="flex flex-1 overflow-hidden">
        {/* Left sidebar - Element Palette */}
        <div className="w-64 border-r border-border bg-card flex flex-col">
          <ElementPalette />
        </div>

        {/* Center - Canvas */}
        <div className="flex-1 flex flex-col overflow-hidden">
          <WatchCanvas />
        </div>

        {/* Right sidebar - Properties & Layers */}
        <div className="w-80 border-l border-border bg-card flex flex-col">
          <PropertiesPanel />
          <LayersPanel />
        </div>
      </div>
    </div>
  )
}
