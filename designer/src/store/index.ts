import { create } from 'zustand'
import { v4 as uuid } from 'uuid'
import type {
  DesignerState,
  WatchFaceProject,
  WatchElement,
  ElementProperties,
  PreviewData,
  Position,
} from './types'

const DEFAULT_PREVIEW_DATA: PreviewData = {
  time: { hour: 10, min: 8, sec: 36 },
  date: { day: 15, month: 4, dayOfWeek: 2, year: 2024 },
  battery: 75,
  steps: 8432,
  stepGoal: 10000,
  heartRate: 72,
}

const DEFAULT_THEME = {
  name: 'Default',
  colors: {
    primary: '#FFFFFF',
    secondary: '#888888',
    accent: '#FFAA00',
    background: '#000000',
    text: '#FFFFFF',
    muted: '#444444',
  },
}

const createDefaultProject = (name: string): WatchFaceProject => ({
  id: uuid(),
  name,
  settings: {
    name,
    targetDevice: 'venusq2',
  },
  elements: [],
  theme: DEFAULT_THEME,
})

const HISTORY_LIMIT = 50

export const useDesignerStore = create<DesignerState>((set, get) => ({
  // Initial state
  project: null,
  isDirty: false,
  selectedElementIds: [],
  hoveredElementId: null,
  zoom: 1,
  panOffset: { x: 0, y: 0 },
  showGrid: true,
  snapToGrid: true,
  gridSize: 10,
  previewData: DEFAULT_PREVIEW_DATA,
  past: [],
  future: [],

  // Project actions
  newProject: (name: string) => {
    set({
      project: createDefaultProject(name),
      isDirty: false,
      selectedElementIds: [],
      past: [],
      future: [],
    })
  },

  setProject: (project: WatchFaceProject) => {
    set({
      project,
      isDirty: false,
      selectedElementIds: [],
      past: [],
      future: [],
    })
  },

  // Element actions
  addElement: (element: WatchElement) => {
    const { project, saveToHistory } = get()
    if (!project) return

    saveToHistory()
    set({
      project: {
        ...project,
        elements: [...project.elements, element],
      },
      isDirty: true,
      selectedElementIds: [element.id],
    })
  },

  updateElement: (id: string, properties: Partial<ElementProperties>) => {
    const { project, saveToHistory } = get()
    if (!project) return

    saveToHistory()
    set({
      project: {
        ...project,
        elements: project.elements.map((el) =>
          el.id === id
            ? { ...el, properties: { ...el.properties, ...properties } }
            : el
        ),
      },
      isDirty: true,
    })
  },

  removeElement: (id: string) => {
    const { project, saveToHistory, selectedElementIds } = get()
    if (!project) return

    saveToHistory()
    set({
      project: {
        ...project,
        elements: project.elements.filter((el) => el.id !== id),
      },
      isDirty: true,
      selectedElementIds: selectedElementIds.filter((sid) => sid !== id),
    })
  },

  duplicateElement: (id: string) => {
    const { project, saveToHistory } = get()
    if (!project) return

    const element = project.elements.find((el) => el.id === id)
    if (!element) return

    const newId = uuid()
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

    saveToHistory()
    set({
      project: {
        ...project,
        elements: [...project.elements, newElement],
      },
      isDirty: true,
      selectedElementIds: [newId],
    })
  },

  reorderElements: (fromIndex: number, toIndex: number) => {
    const { project, saveToHistory } = get()
    if (!project) return

    const elements = [...project.elements]
    const [removed] = elements.splice(fromIndex, 1)
    elements.splice(toIndex, 0, removed)

    // Update zIndex based on new order
    const reindexed = elements.map((el, idx) => ({
      ...el,
      properties: { ...el.properties, zIndex: idx },
    }))

    saveToHistory()
    set({
      project: { ...project, elements: reindexed },
      isDirty: true,
    })
  },

  selectElements: (ids: string[]) => {
    set({ selectedElementIds: ids })
  },

  setHoveredElement: (id: string | null) => {
    set({ hoveredElementId: id })
  },

  toggleElementVisibility: (id: string) => {
    const { project } = get()
    if (!project) return

    set({
      project: {
        ...project,
        elements: project.elements.map((el) =>
          el.id === id
            ? { ...el, properties: { ...el.properties, visible: !el.properties.visible } }
            : el
        ),
      },
      isDirty: true,
    })
  },

  toggleElementLock: (id: string) => {
    const { project } = get()
    if (!project) return

    set({
      project: {
        ...project,
        elements: project.elements.map((el) =>
          el.id === id
            ? { ...el, properties: { ...el.properties, locked: !el.properties.locked } }
            : el
        ),
      },
      isDirty: true,
    })
  },

  // Canvas actions
  setZoom: (zoom: number) => {
    set({ zoom: Math.max(0.25, Math.min(4, zoom)) })
  },

  setPanOffset: (offset: Position) => {
    set({ panOffset: offset })
  },

  toggleGrid: () => {
    set((state) => ({ showGrid: !state.showGrid }))
  },

  toggleSnapToGrid: () => {
    set((state) => ({ snapToGrid: !state.snapToGrid }))
  },

  // Preview actions
  setPreviewData: (data: Partial<PreviewData>) => {
    set((state) => ({
      previewData: { ...state.previewData, ...data },
    }))
  },

  // History actions
  saveToHistory: () => {
    const { project, past } = get()
    if (!project) return

    set({
      past: [...past.slice(-HISTORY_LIMIT + 1), project],
      future: [],
    })
  },

  undo: () => {
    const { past, project, future } = get()
    if (past.length === 0 || !project) return

    const previous = past[past.length - 1]
    const newPast = past.slice(0, -1)

    set({
      past: newPast,
      project: previous,
      future: [project, ...future],
      isDirty: true,
    })
  },

  redo: () => {
    const { past, project, future } = get()
    if (future.length === 0 || !project) return

    const next = future[0]
    const newFuture = future.slice(1)

    set({
      past: [...past, project],
      project: next,
      future: newFuture,
      isDirty: true,
    })
  },

  // Alignment actions
  alignElements: (alignment: 'left' | 'center-h' | 'right' | 'top' | 'center-v' | 'bottom') => {
    const { project, selectedElementIds, saveToHistory } = get()
    if (!project || selectedElementIds.length === 0) return

    const selectedElements = project.elements.filter(
      (el) => selectedElementIds.includes(el.id) && !el.properties.locked
    )
    if (selectedElements.length === 0) return

    saveToHistory()

    // For single element, align to canvas. For multiple, align to each other.
    const canvasWidth = 320
    const canvasHeight = 360

    const updates: { id: string; props: { x?: number; y?: number } }[] = []

    if (selectedElements.length === 1) {
      // Align single element to canvas
      const el = selectedElements[0]
      const { width, height } = el.properties

      switch (alignment) {
        case 'left':
          updates.push({ id: el.id, props: { x: 0 } })
          break
        case 'center-h':
          updates.push({ id: el.id, props: { x: (canvasWidth - width) / 2 } })
          break
        case 'right':
          updates.push({ id: el.id, props: { x: canvasWidth - width } })
          break
        case 'top':
          updates.push({ id: el.id, props: { y: 0 } })
          break
        case 'center-v':
          updates.push({ id: el.id, props: { y: (canvasHeight - height) / 2 } })
          break
        case 'bottom':
          updates.push({ id: el.id, props: { y: canvasHeight - height } })
          break
      }
    } else {
      // Align multiple elements to each other
      const bounds = selectedElements.reduce(
        (acc, el) => ({
          minX: Math.min(acc.minX, el.properties.x),
          maxX: Math.max(acc.maxX, el.properties.x + el.properties.width),
          minY: Math.min(acc.minY, el.properties.y),
          maxY: Math.max(acc.maxY, el.properties.y + el.properties.height),
        }),
        { minX: Infinity, maxX: -Infinity, minY: Infinity, maxY: -Infinity }
      )

      for (const el of selectedElements) {
        const { width, height } = el.properties
        switch (alignment) {
          case 'left':
            updates.push({ id: el.id, props: { x: bounds.minX } })
            break
          case 'center-h':
            updates.push({ id: el.id, props: { x: (bounds.minX + bounds.maxX - width) / 2 } })
            break
          case 'right':
            updates.push({ id: el.id, props: { x: bounds.maxX - width } })
            break
          case 'top':
            updates.push({ id: el.id, props: { y: bounds.minY } })
            break
          case 'center-v':
            updates.push({ id: el.id, props: { y: (bounds.minY + bounds.maxY - height) / 2 } })
            break
          case 'bottom':
            updates.push({ id: el.id, props: { y: bounds.maxY - height } })
            break
        }
      }
    }

    // Apply updates
    set({
      project: {
        ...project,
        elements: project.elements.map((el) => {
          const update = updates.find((u) => u.id === el.id)
          if (update) {
            return { ...el, properties: { ...el.properties, ...update.props } }
          }
          return el
        }),
      },
      isDirty: true,
    })
  },

  distributeElements: (direction: 'horizontal' | 'vertical') => {
    const { project, selectedElementIds, saveToHistory } = get()
    if (!project || selectedElementIds.length < 3) return

    const selectedElements = project.elements
      .filter((el) => selectedElementIds.includes(el.id) && !el.properties.locked)
      .sort((a, b) =>
        direction === 'horizontal'
          ? a.properties.x - b.properties.x
          : a.properties.y - b.properties.y
      )

    if (selectedElements.length < 3) return

    saveToHistory()

    const first = selectedElements[0]
    const last = selectedElements[selectedElements.length - 1]

    const totalSpace =
      direction === 'horizontal'
        ? last.properties.x - first.properties.x
        : last.properties.y - first.properties.y

    const step = totalSpace / (selectedElements.length - 1)

    const updates = selectedElements.map((el, i) => ({
      id: el.id,
      props:
        direction === 'horizontal'
          ? { x: first.properties.x + step * i }
          : { y: first.properties.y + step * i },
    }))

    set({
      project: {
        ...project,
        elements: project.elements.map((el) => {
          const update = updates.find((u) => u.id === el.id)
          if (update) {
            return { ...el, properties: { ...el.properties, ...update.props } }
          }
          return el
        }),
      },
      isDirty: true,
    })
  },
}))
