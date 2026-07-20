interface FileResult {
  success: boolean
  content?: string
  error?: string
}

interface BuildResult {
  success: boolean
  stdout: string
  stderr: string
  code: number
}

interface SaveDialogResult {
  canceled: boolean
  filePath?: string
}

interface OpenDialogResult {
  canceled: boolean
  filePaths: string[]
}

interface ElectronAPI {
  fs: {
    readFile: (filePath: string) => Promise<FileResult>
    writeFile: (filePath: string, content: string) => Promise<FileResult>
    mkdir: (dirPath: string) => Promise<FileResult>
    exists: (filePath: string) => Promise<boolean>
    copyFile: (src: string, dest: string) => Promise<FileResult>
  }
  app: {
    getProjectRoot: () => Promise<string>
  }
  build: {
    run: (faceName: string, device?: string) => Promise<BuildResult>
    runSimulator: (faceName: string) => Promise<BuildResult>
  }
  shell: {
    openPath: (folderPath: string) => Promise<void>
  }
  dialog: {
    saveProject: () => Promise<SaveDialogResult>
    openProject: () => Promise<OpenDialogResult>
  }
}

declare global {
  interface Window {
    electronAPI: ElectronAPI
  }
}

export {}
