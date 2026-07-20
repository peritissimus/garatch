import { contextBridge, ipcRenderer } from 'electron'

// Expose protected methods to the renderer process
contextBridge.exposeInMainWorld('electronAPI', {
  // File system operations
  fs: {
    readFile: (filePath: string) => ipcRenderer.invoke('fs:readFile', filePath),
    writeFile: (filePath: string, content: string) =>
      ipcRenderer.invoke('fs:writeFile', filePath, content),
    mkdir: (dirPath: string) => ipcRenderer.invoke('fs:mkdir', dirPath),
    exists: (filePath: string) => ipcRenderer.invoke('fs:exists', filePath),
    copyFile: (src: string, dest: string) => ipcRenderer.invoke('fs:copyFile', src, dest),
  },

  // App info
  app: {
    getProjectRoot: () => ipcRenderer.invoke('app:getProjectRoot'),
  },

  // Build integration
  build: {
    run: (faceName: string, device?: string) =>
      ipcRenderer.invoke('build:run', faceName, device),
    runSimulator: (faceName: string) =>
      ipcRenderer.invoke('build:runSimulator', faceName),
  },

  // Shell operations
  shell: {
    openPath: (folderPath: string) => ipcRenderer.invoke('shell:openPath', folderPath),
  },

  // File dialogs
  dialog: {
    saveProject: () => ipcRenderer.invoke('dialog:saveProject'),
    openProject: () => ipcRenderer.invoke('dialog:openProject'),
  },
})
