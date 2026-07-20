import { app, BrowserWindow, ipcMain, shell, dialog } from 'electron'
import path from 'path'
import fs from 'fs'
import { spawn } from 'child_process'
import { fileURLToPath } from 'url'

// Get __dirname equivalent for ES modules
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const isDev = process.env.NODE_ENV === 'development' || !app.isPackaged

let mainWindow: BrowserWindow | null = null

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 1200,
    minHeight: 700,
    backgroundColor: '#0a0a0a',
    titleBarStyle: 'hiddenInset',
    trafficLightPosition: { x: 16, y: 16 },
    webPreferences: {
      preload: path.join(__dirname, 'preload.mjs'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  })

  if (isDev) {
    mainWindow.loadURL('http://localhost:5173')
    mainWindow.webContents.openDevTools()
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'))
  }

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

app.whenReady().then(createWindow)

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow()
  }
})

// IPC Handlers for file operations
ipcMain.handle('fs:readFile', async (_, filePath: string) => {
  try {
    const content = await fs.promises.readFile(filePath, 'utf-8')
    return { success: true, content }
  } catch (error) {
    return { success: false, error: String(error) }
  }
})

ipcMain.handle('fs:writeFile', async (_, filePath: string, content: string) => {
  try {
    await fs.promises.mkdir(path.dirname(filePath), { recursive: true })
    await fs.promises.writeFile(filePath, content, 'utf-8')
    return { success: true }
  } catch (error) {
    return { success: false, error: String(error) }
  }
})

ipcMain.handle('fs:mkdir', async (_, dirPath: string) => {
  try {
    await fs.promises.mkdir(dirPath, { recursive: true })
    return { success: true }
  } catch (error) {
    return { success: false, error: String(error) }
  }
})

ipcMain.handle('fs:exists', async (_, filePath: string) => {
  try {
    await fs.promises.access(filePath)
    return true
  } catch {
    return false
  }
})

ipcMain.handle('fs:copyFile', async (_, src: string, dest: string) => {
  try {
    await fs.promises.mkdir(path.dirname(dest), { recursive: true })
    await fs.promises.copyFile(src, dest)
    return { success: true }
  } catch (error) {
    return { success: false, error: String(error) }
  }
})

// Get the project root (garatch directory)
ipcMain.handle('app:getProjectRoot', () => {
  // In dev, go up from designer/, in prod this needs adjustment
  return path.resolve(__dirname, '../../')
})

// Build integration
ipcMain.handle('build:run', async (_, faceName: string, device: string = 'venusq2') => {
  return new Promise((resolve) => {
    const projectRoot = path.resolve(__dirname, '../../')
    const makeProcess = spawn('make', ['build', `FACE=${faceName}`, `DEVICE=${device}`], {
      cwd: projectRoot,
      shell: true,
    })

    let stdout = ''
    let stderr = ''

    makeProcess.stdout.on('data', (data) => {
      stdout += data.toString()
    })

    makeProcess.stderr.on('data', (data) => {
      stderr += data.toString()
    })

    makeProcess.on('close', (code) => {
      resolve({
        success: code === 0,
        stdout,
        stderr,
        code,
      })
    })
  })
})

ipcMain.handle('build:runSimulator', async (_, faceName: string) => {
  return new Promise((resolve) => {
    const projectRoot = path.resolve(__dirname, '../../')
    const makeProcess = spawn('make', ['run', `FACE=${faceName}`], {
      cwd: projectRoot,
      shell: true,
    })

    let stdout = ''
    let stderr = ''

    makeProcess.stdout.on('data', (data) => {
      stdout += data.toString()
    })

    makeProcess.stderr.on('data', (data) => {
      stderr += data.toString()
    })

    makeProcess.on('close', (code) => {
      resolve({
        success: code === 0,
        stdout,
        stderr,
        code,
      })
    })
  })
})

// Open folder in Finder/Explorer
ipcMain.handle('shell:openPath', async (_, folderPath: string) => {
  shell.openPath(folderPath)
})

// File dialogs for project save/open
ipcMain.handle('dialog:saveProject', async () => {
  if (!mainWindow) return { canceled: true }

  const result = await dialog.showSaveDialog(mainWindow, {
    title: 'Save Watch Face Project',
    defaultPath: 'my-watch-face.garatch',
    filters: [
      { name: 'Garatch Project', extensions: ['garatch'] },
      { name: 'JSON', extensions: ['json'] },
    ],
  })

  return result
})

ipcMain.handle('dialog:openProject', async () => {
  if (!mainWindow) return { canceled: true, filePaths: [] }

  const result = await dialog.showOpenDialog(mainWindow, {
    title: 'Open Watch Face Project',
    filters: [
      { name: 'Garatch Project', extensions: ['garatch'] },
      { name: 'JSON', extensions: ['json'] },
    ],
    properties: ['openFile'],
  })

  return result
})
