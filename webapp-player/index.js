const { app, BrowserWindow } = require('electron/main')
const path = require('node:path')

function createWindow () {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    darkTheme: true,
    menuBarVisible: false,
    title: process.argv[3],
    icon: process.argv[4],
    webPreferences: {
      devTools: false,
      spellcheck: false,
      enableWebSQL: false,
    }
  });
  win.setMenu(null);
  win.setBackgroundColor('black')
  win.loadURL(process.argv[2])
}

app.whenReady().then(() => {
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})
