import { useState, useEffect } from 'react'
import { Download, FolderOpen, Check, AlertCircle, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { ScrollArea } from '@/components/ui/scroll-area'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useDesignerStore } from '@/store'
import { generateWatchFace, getFolderStructure, previewViewMc, toFolderName } from '@/codegen'

interface ExportDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

type ExportStatus = 'idle' | 'exporting' | 'success' | 'error'

export function ExportDialog({ open, onOpenChange }: ExportDialogProps) {
  const { project } = useDesignerStore()
  const [projectName, setProjectName] = useState(project?.name || 'My Watch Face')
  const [device, setDevice] = useState<'venusq2' | 'venusq2m'>('venusq2')
  const [status, setStatus] = useState<ExportStatus>('idle')
  const [exportPath, setExportPath] = useState('')
  const [errorMessage, setErrorMessage] = useState('')
  const [activeTab, setActiveTab] = useState<'structure' | 'preview'>('structure')

  // Reset state when dialog opens
  useEffect(() => {
    if (open) {
      setProjectName(project?.name || 'My Watch Face')
      setStatus('idle')
      setErrorMessage('')
    }
  }, [open, project?.name])

  if (!open || !project) return null

  const folderName = toFolderName(projectName)
  const folderStructure = getFolderStructure({ ...project, name: projectName })
  const codePreview = previewViewMc({ ...project, name: projectName })

  const handleExport = async () => {
    setStatus('exporting')
    setErrorMessage('')

    try {
      // Update project name in settings
      const projectToExport = {
        ...project,
        name: projectName,
        settings: {
          ...project.settings,
          name: projectName,
          targetDevice: device,
        },
      }

      // Generate files
      const result = generateWatchFace(projectToExport)

      if (!result.success) {
        throw new Error(result.error || 'Failed to generate watch face')
      }

      // Get project root from Electron
      const projectRoot = await window.electronAPI.app.getProjectRoot()
      const facesPath = `${projectRoot}/faces/${result.folderName}`

      // Create directories
      await window.electronAPI.fs.mkdir(`${facesPath}/source`)
      await window.electronAPI.fs.mkdir(`${facesPath}/resources/drawables`)
      await window.electronAPI.fs.mkdir(`${facesPath}/resources/strings`)
      await window.electronAPI.fs.mkdir(`${facesPath}/resources/layouts`)

      // Write all generated files
      for (const file of result.files) {
        const filePath = `${facesPath}/${file.path}`
        const writeResult = await window.electronAPI.fs.writeFile(filePath, file.content)
        if (!writeResult.success) {
          throw new Error(`Failed to write ${file.path}: ${writeResult.error}`)
        }
      }

      // Copy launcher icon from an existing face
      const iconSource = `${projectRoot}/faces/garatch-minimal/resources/drawables/launcher_icon.png`
      const iconDest = `${facesPath}/resources/drawables/launcher_icon.png`
      await window.electronAPI.fs.copyFile(iconSource, iconDest)

      setExportPath(facesPath)
      setStatus('success')
    } catch (error) {
      setStatus('error')
      setErrorMessage(String(error))
    }
  }

  const handleOpenFolder = () => {
    if (exportPath) {
      window.electronAPI.shell.openPath(exportPath)
    }
  }

  const handleClose = () => {
    onOpenChange(false)
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={handleClose}
      />

      {/* Modal */}
      <div className="relative bg-card border border-border rounded-xl shadow-2xl w-full max-w-3xl max-h-[80vh] flex flex-col m-4">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-border">
          <div>
            <h2 className="text-lg font-semibold flex items-center gap-2">
              <Download className="h-5 w-5" />
              Export Watch Face
            </h2>
            <p className="text-sm text-muted-foreground">
              Generate MonkeyC code for your watch face design
            </p>
          </div>
          <Button variant="ghost" size="icon" onClick={handleClose}>
            <X className="h-4 w-4" />
          </Button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-auto p-6">
          {status === 'success' ? (
            <div className="flex flex-col items-center justify-center py-8 gap-4">
              <div className="h-16 w-16 rounded-full bg-green-500/20 flex items-center justify-center">
                <Check className="h-8 w-8 text-green-500" />
              </div>
              <h3 className="text-lg font-medium">Export Successful!</h3>
              <p className="text-sm text-muted-foreground text-center">
                Your watch face has been exported to:
                <br />
                <code className="text-xs bg-muted px-2 py-1 rounded mt-1 inline-block">
                  faces/{folderName}/
                </code>
              </p>
              <div className="flex gap-2 mt-4">
                <Button variant="outline" onClick={handleOpenFolder}>
                  <FolderOpen className="h-4 w-4 mr-2" />
                  Open Folder
                </Button>
                <Button onClick={handleClose}>Done</Button>
              </div>
            </div>
          ) : status === 'error' ? (
            <div className="flex flex-col items-center justify-center py-8 gap-4">
              <div className="h-16 w-16 rounded-full bg-red-500/20 flex items-center justify-center">
                <AlertCircle className="h-8 w-8 text-red-500" />
              </div>
              <h3 className="text-lg font-medium">Export Failed</h3>
              <p className="text-sm text-muted-foreground text-center max-w-md">
                {errorMessage}
              </p>
              <Button onClick={() => setStatus('idle')}>Try Again</Button>
            </div>
          ) : (
            <div className="space-y-6">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="name">Project Name</Label>
                  <Input
                    id="name"
                    value={projectName}
                    onChange={(e) => setProjectName(e.target.value)}
                    placeholder="My Watch Face"
                  />
                  <p className="text-xs text-muted-foreground">
                    Folder: <code>faces/{folderName}/</code>
                  </p>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="device">Target Device</Label>
                  <Select value={device} onValueChange={(v) => setDevice(v as 'venusq2' | 'venusq2m')}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="venusq2">Venu Sq 2</SelectItem>
                      <SelectItem value="venusq2m">Venu Sq 2 Music</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              {/* Tabs */}
              <div>
                <div className="flex border-b border-border">
                  <button
                    className={`px-4 py-2 text-sm font-medium transition-colors ${
                      activeTab === 'structure'
                        ? 'border-b-2 border-primary text-foreground'
                        : 'text-muted-foreground hover:text-foreground'
                    }`}
                    onClick={() => setActiveTab('structure')}
                  >
                    File Structure
                  </button>
                  <button
                    className={`px-4 py-2 text-sm font-medium transition-colors ${
                      activeTab === 'preview'
                        ? 'border-b-2 border-primary text-foreground'
                        : 'text-muted-foreground hover:text-foreground'
                    }`}
                    onClick={() => setActiveTab('preview')}
                  >
                    Code Preview
                  </button>
                </div>

                <div className="mt-4">
                  {activeTab === 'structure' ? (
                    <ScrollArea className="h-[200px] rounded-md border bg-muted/30 p-4">
                      <pre className="text-xs font-mono">
                        {folderStructure.map((path, i) => (
                          <div key={i} className="text-muted-foreground">
                            {path}
                          </div>
                        ))}
                      </pre>
                    </ScrollArea>
                  ) : (
                    <ScrollArea className="h-[200px] rounded-md border bg-muted/30 p-4">
                      <pre className="text-xs font-mono whitespace-pre-wrap text-muted-foreground">
                        {codePreview}
                      </pre>
                    </ScrollArea>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        {status === 'idle' && (
          <div className="flex justify-end gap-2 px-6 py-4 border-t border-border">
            <Button variant="outline" onClick={handleClose}>
              Cancel
            </Button>
            <Button onClick={handleExport}>
              <Download className="h-4 w-4 mr-2" />
              Export
            </Button>
          </div>
        )}
      </div>
    </div>
  )
}
