import { useState } from 'react'
import {
  FilePlus,
  FolderOpen,
  Save,
  Download,
  Play,
  Undo,
  Redo,
  Grid3X3,
  Magnet,
  ZoomIn,
  ZoomOut,
  Loader2,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import { useDesignerStore } from '@/store'
import { ExportDialog } from '@/components/dialogs/ExportDialog'
import { ImportDialog } from '@/components/dialogs/ImportDialog'
import { TemplatesDialog } from '@/components/dialogs/TemplatesDialog'
import { toFolderName } from '@/codegen'
import type { WatchFaceProject } from '@/store/types'

export function Toolbar() {
  const {
    project,
    zoom,
    setZoom,
    showGrid,
    toggleGrid,
    snapToGrid,
    toggleSnapToGrid,
    undo,
    redo,
    past,
    future,
    setProject,
    isDirty,
  } = useDesignerStore()

  const [exportDialogOpen, setExportDialogOpen] = useState(false)
  const [importDialogOpen, setImportDialogOpen] = useState(false)
  const [templatesDialogOpen, setTemplatesDialogOpen] = useState(false)
  const [isBuilding, setIsBuilding] = useState(false)
  const [, setBuildStatus] = useState<'idle' | 'success' | 'error'>('idle')
  const [currentFilePath, setCurrentFilePath] = useState<string | null>(null)
  const [isSaving, setIsSaving] = useState(false)

  const canUndo = past.length > 0
  const canRedo = future.length > 0

  const handleNewProject = () => {
    setTemplatesDialogOpen(true)
  }

  const handleSaveProject = async () => {
    if (!project) return

    setIsSaving(true)
    try {
      let filePath = currentFilePath

      // If no current file, show save dialog
      if (!filePath) {
        const result = await window.electronAPI.dialog.saveProject()
        if (result.canceled || !result.filePath) {
          setIsSaving(false)
          return
        }
        filePath = result.filePath
      }

      // Save project as JSON
      const projectData = JSON.stringify(project, null, 2)
      const writeResult = await window.electronAPI.fs.writeFile(filePath, projectData)

      if (writeResult.success) {
        setCurrentFilePath(filePath)
        // Mark as not dirty
        useDesignerStore.setState({ isDirty: false })
      } else {
        alert(`Failed to save: ${writeResult.error}`)
      }
    } catch (error) {
      alert(`Error saving project: ${error}`)
    } finally {
      setIsSaving(false)
    }
  }

  const handleOpenProject = async () => {
    if (isDirty && !confirm('Open a different project? Unsaved changes will be lost.')) {
      return
    }

    try {
      const result = await window.electronAPI.dialog.openProject()
      if (result.canceled || result.filePaths.length === 0) {
        return
      }

      const filePath = result.filePaths[0]
      const readResult = await window.electronAPI.fs.readFile(filePath)

      if (!readResult.success || !readResult.content) {
        alert(`Failed to open: ${readResult.error}`)
        return
      }

      const loadedProject = JSON.parse(readResult.content) as WatchFaceProject
      setProject(loadedProject)
      setCurrentFilePath(filePath)
    } catch (error) {
      alert(`Error opening project: ${error}`)
    }
  }

  const handleBuildAndRun = async () => {
    if (!project || project.elements.length === 0) {
      alert('Please add some elements before building')
      return
    }

    setIsBuilding(true)
    setBuildStatus('idle')

    try {
      const folderName = toFolderName(project.name)

      // First check if the project has been exported
      const projectRoot = await window.electronAPI.app.getProjectRoot()
      const exists = await window.electronAPI.fs.exists(`${projectRoot}/faces/${folderName}/manifest.xml`)

      if (!exists) {
        alert('Please export the watch face first before building')
        setExportDialogOpen(true)
        setIsBuilding(false)
        return
      }

      // Run the build
      const result = await window.electronAPI.build.runSimulator(folderName)

      if (result.success) {
        setBuildStatus('success')
      } else {
        setBuildStatus('error')
        console.error('Build failed:', result.stderr)
        alert(`Build failed:\n${result.stderr || result.stdout}`)
      }
    } catch (error) {
      setBuildStatus('error')
      alert(`Build error: ${error}`)
    } finally {
      setIsBuilding(false)
    }
  }

  return (
    <>
      <div className="h-12 px-4 flex items-center gap-1 bg-card border-b border-border titlebar-no-drag">
        {/* File operations */}
        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8"
          title="New Project"
          onClick={handleNewProject}
        >
          <FilePlus className="h-4 w-4" />
        </Button>

        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8"
          title="Open Project (.garatch file)"
          onClick={handleOpenProject}
        >
          <FolderOpen className="h-4 w-4" />
        </Button>

        <Button
          variant="ghost"
          size="sm"
          className="h-8 text-xs px-2"
          title="Import from existing faces"
          onClick={() => setImportDialogOpen(true)}
        >
          Import
        </Button>

        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8"
          title={currentFilePath ? `Save Project (${currentFilePath.split('/').pop()})` : 'Save Project'}
          onClick={handleSaveProject}
          disabled={isSaving || !project}
        >
          {isSaving ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Save className="h-4 w-4" />
          )}
        </Button>

        <Separator orientation="vertical" className="h-6 mx-2" />

        {/* History */}
        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8"
          disabled={!canUndo}
          onClick={undo}
          title="Undo"
        >
          <Undo className="h-4 w-4" />
        </Button>

        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8"
          disabled={!canRedo}
          onClick={redo}
          title="Redo"
        >
          <Redo className="h-4 w-4" />
        </Button>

        <Separator orientation="vertical" className="h-6 mx-2" />

        {/* Canvas controls */}
        <Button
          variant={showGrid ? 'secondary' : 'ghost'}
          size="icon"
          className="h-8 w-8"
          onClick={toggleGrid}
          title="Toggle Grid"
        >
          <Grid3X3 className="h-4 w-4" />
        </Button>

        <Button
          variant={snapToGrid ? 'secondary' : 'ghost'}
          size="icon"
          className="h-8 w-8"
          onClick={toggleSnapToGrid}
          title="Snap to Grid"
        >
          <Magnet className="h-4 w-4" />
        </Button>

        <Separator orientation="vertical" className="h-6 mx-2" />

        {/* Zoom */}
        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8"
          onClick={() => setZoom(zoom - 0.25)}
          disabled={zoom <= 0.25}
          title="Zoom Out"
        >
          <ZoomOut className="h-4 w-4" />
        </Button>

        <span className="text-xs text-muted-foreground w-12 text-center">
          {Math.round(zoom * 100)}%
        </span>

        <Button
          variant="ghost"
          size="icon"
          className="h-8 w-8"
          onClick={() => setZoom(zoom + 0.25)}
          disabled={zoom >= 4}
          title="Zoom In"
        >
          <ZoomIn className="h-4 w-4" />
        </Button>

        {/* Spacer */}
        <div className="flex-1" />

        {/* Project name */}
        <span className="text-sm text-muted-foreground mr-4">
          {isDirty && '• '}
          {project?.name || 'Untitled'}
          {currentFilePath && (
            <span className="text-xs ml-1 opacity-60">
              ({currentFilePath.split('/').pop()})
            </span>
          )}
        </span>

        {/* Export & Build */}
        <Button
          variant="outline"
          size="sm"
          className="h-8 gap-2"
          title="Export Watch Face"
          onClick={() => setExportDialogOpen(true)}
        >
          <Download className="h-4 w-4" />
          Export
        </Button>

        <Button
          size="sm"
          className="h-8 gap-2 ml-2"
          title="Build & Run in Simulator"
          onClick={handleBuildAndRun}
          disabled={isBuilding}
        >
          {isBuilding ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Building...
            </>
          ) : (
            <>
              <Play className="h-4 w-4" />
              Run
            </>
          )}
        </Button>
      </div>

      <ExportDialog open={exportDialogOpen} onOpenChange={setExportDialogOpen} />
      <ImportDialog open={importDialogOpen} onOpenChange={setImportDialogOpen} />
      <TemplatesDialog open={templatesDialogOpen} onOpenChange={setTemplatesDialogOpen} />
    </>
  )
}
