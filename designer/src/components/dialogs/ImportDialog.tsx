import { useState, useEffect } from 'react'
import { FolderOpen, Check, Loader2, X, Watch } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ScrollArea } from '@/components/ui/scroll-area'
import { useDesignerStore } from '@/store'
import { v4 as uuid } from 'uuid'
import type { WatchFaceProject } from '@/store/types'

interface ImportDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

interface FaceInfo {
  name: string
  folderName: string
  hasManifest: boolean
}

export function ImportDialog({ open, onOpenChange }: ImportDialogProps) {
  const { setProject } = useDesignerStore()
  const [faces, setFaces] = useState<FaceInfo[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedFace, setSelectedFace] = useState<string | null>(null)
  const [importing, setImporting] = useState(false)

  // Load faces list when dialog opens
  useEffect(() => {
    if (open) {
      loadFaces()
    }
  }, [open])

  const loadFaces = async () => {
    setLoading(true)
    try {
      const projectRoot = await window.electronAPI.app.getProjectRoot()
      const facesPath = `${projectRoot}/faces`

      // Read the faces directory by checking each known face
      // We'll check for manifest.xml to verify it's a valid face
      const knownFaces = [
        'basic',
        'garatch-analog',
        'garatch-blueprint',
        'garatch-cosmic',
        'garatch-ghibli',
        'garatch-ghibli2',
        'garatch-metrics',
        'garatch-minimal',
      ]

      const faceInfos: FaceInfo[] = []

      for (const folderName of knownFaces) {
        const manifestPath = `${facesPath}/${folderName}/manifest.xml`
        const hasManifest = await window.electronAPI.fs.exists(manifestPath)

        if (hasManifest) {
          // Try to read the manifest to get the app name
          const result = await window.electronAPI.fs.readFile(manifestPath)
          let displayName = folderName

          if (result.success && result.content) {
            // Extract name from manifest
            const nameMatch = result.content.match(/entry="[^"]*App"[^>]*name="([^"]+)"/)
            if (nameMatch) {
              displayName = nameMatch[1]
            }
          }

          faceInfos.push({
            name: displayName,
            folderName,
            hasManifest: true,
          })
        }
      }

      setFaces(faceInfos)
    } catch (error) {
      console.error('Failed to load faces:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleImport = async () => {
    if (!selectedFace) return

    setImporting(true)
    try {
      const face = faces.find((f) => f.folderName === selectedFace)
      if (!face) return

      // Create a new project based on this face
      const newProject: WatchFaceProject = {
        id: uuid(),
        name: face.name,
        settings: {
          name: face.name,
          targetDevice: 'venusq2',
        },
        elements: [],
        theme: {
          name: 'Default',
          colors: {
            primary: '#FFFFFF',
            secondary: '#888888',
            accent: '#FFAA00',
            background: '#000000',
            text: '#FFFFFF',
            muted: '#444444',
          },
        },
      }

      setProject(newProject)
      onOpenChange(false)
    } catch (error) {
      console.error('Failed to import:', error)
    } finally {
      setImporting(false)
    }
  }

  const handleClose = () => {
    onOpenChange(false)
  }

  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={handleClose}
      />

      {/* Modal */}
      <div className="relative bg-card border border-border rounded-xl shadow-2xl w-full max-w-md max-h-[70vh] flex flex-col m-4">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-border">
          <div>
            <h2 className="text-lg font-semibold flex items-center gap-2">
              <FolderOpen className="h-5 w-5" />
              Import from Faces
            </h2>
            <p className="text-sm text-muted-foreground">
              Select an existing watch face as a starting point
            </p>
          </div>
          <Button variant="ghost" size="icon" onClick={handleClose}>
            <X className="h-4 w-4" />
          </Button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-auto p-4">
          {loading ? (
            <div className="flex items-center justify-center py-8">
              <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
            </div>
          ) : faces.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              No watch faces found in faces/ directory
            </div>
          ) : (
            <ScrollArea className="h-[300px]">
              <div className="space-y-2">
                {faces.map((face) => (
                  <button
                    key={face.folderName}
                    onClick={() => setSelectedFace(face.folderName)}
                    className={`w-full flex items-center gap-3 p-3 rounded-lg border transition-colors text-left ${
                      selectedFace === face.folderName
                        ? 'border-primary bg-primary/10'
                        : 'border-border hover:border-muted-foreground/50 hover:bg-muted/50'
                    }`}
                  >
                    <div className="h-10 w-10 rounded-lg bg-muted flex items-center justify-center">
                      <Watch className="h-5 w-5 text-muted-foreground" />
                    </div>
                    <div className="flex-1">
                      <div className="font-medium">{face.name}</div>
                      <div className="text-xs text-muted-foreground">
                        faces/{face.folderName}/
                      </div>
                    </div>
                    {selectedFace === face.folderName && (
                      <Check className="h-5 w-5 text-primary" />
                    )}
                  </button>
                ))}
              </div>
            </ScrollArea>
          )}

          <p className="text-xs text-muted-foreground mt-4">
            Note: This creates a new empty project with the face's name.
            The original MonkeyC code cannot be automatically converted to visual elements.
          </p>
        </div>

        {/* Footer */}
        <div className="flex justify-end gap-2 px-6 py-4 border-t border-border">
          <Button variant="outline" onClick={handleClose}>
            Cancel
          </Button>
          <Button
            onClick={handleImport}
            disabled={!selectedFace || importing}
          >
            {importing ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Importing...
              </>
            ) : (
              <>
                <FolderOpen className="h-4 w-4 mr-2" />
                Import
              </>
            )}
          </Button>
        </div>
      </div>
    </div>
  )
}
