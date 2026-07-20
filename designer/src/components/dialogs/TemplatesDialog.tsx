import { useState } from 'react'
import { LayoutTemplate, Check, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { useDesignerStore } from '@/store'
import { templates } from '@/lib/templates'

interface TemplatesDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function TemplatesDialog({ open, onOpenChange }: TemplatesDialogProps) {
  const { setProject, isDirty } = useDesignerStore()
  const [selectedTemplate, setSelectedTemplate] = useState<string | null>(null)

  const handleUseTemplate = () => {
    if (!selectedTemplate) return

    if (isDirty && !confirm('Use this template? Unsaved changes will be lost.')) {
      return
    }

    const template = templates.find((t) => t.id === selectedTemplate)
    if (template) {
      const project = template.create()
      setProject(project)
      onOpenChange(false)
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
      <div className="relative bg-card border border-border rounded-xl shadow-2xl w-full max-w-2xl max-h-[80vh] flex flex-col m-4">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-border">
          <div>
            <h2 className="text-lg font-semibold flex items-center gap-2">
              <LayoutTemplate className="h-5 w-5" />
              Choose a Template
            </h2>
            <p className="text-sm text-muted-foreground">
              Start with a pre-built layout or empty canvas
            </p>
          </div>
          <Button variant="ghost" size="icon" onClick={handleClose}>
            <X className="h-4 w-4" />
          </Button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-auto p-6">
          <div className="grid grid-cols-2 gap-4">
            {templates.map((template) => (
              <button
                key={template.id}
                onClick={() => setSelectedTemplate(template.id)}
                className={`relative flex flex-col items-center p-6 rounded-xl border-2 transition-all text-center ${
                  selectedTemplate === template.id
                    ? 'border-primary bg-primary/10 shadow-lg'
                    : 'border-border hover:border-muted-foreground/50 hover:bg-muted/30'
                }`}
              >
                <span className="text-4xl mb-3">{template.preview}</span>
                <span className="font-medium">{template.name}</span>
                <span className="text-xs text-muted-foreground mt-1">
                  {template.description}
                </span>
                {selectedTemplate === template.id && (
                  <div className="absolute top-2 right-2">
                    <Check className="h-5 w-5 text-primary" />
                  </div>
                )}
              </button>
            ))}
          </div>
        </div>

        {/* Footer */}
        <div className="flex justify-end gap-2 px-6 py-4 border-t border-border">
          <Button variant="outline" onClick={handleClose}>
            Cancel
          </Button>
          <Button onClick={handleUseTemplate} disabled={!selectedTemplate}>
            <LayoutTemplate className="h-4 w-4 mr-2" />
            Use Template
          </Button>
        </div>
      </div>
    </div>
  )
}
