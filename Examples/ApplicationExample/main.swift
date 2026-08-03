// Application example — wires up an app: a menu bar, a primary window, and
// lifecycle events, then runs the event loop.
//
// This one *does* open a window and block. Pass --dry-run to exercise
// everything except the loop, which is what CI does.
//
// Usage:
//   swift run ApplicationExample
//   swift run ApplicationExample --dry-run

import Foundation
import NativeAPI

let dryRun = CommandLine.arguments.contains("--dry-run")

// --- 1. Lifecycle events ---
let listener = Application.addListener { event in
  switch event {
  case .started: print("[app] started")
  case .exiting(let exitCode): print("[app] exiting (\(exitCode))")
  case .activated: print("[app] activated")
  case .deactivated: print("[app] deactivated")
  case .quitRequested:
    print("[app] quit requested")
    Application.quit(exitCode: 0)
  }
}

print("Single instance: \(Application.isSingleInstance())")

// --- 2. Menu bar ---
if let menuBar = Menu.create() {
  if let about = MenuItem.createWithLabelAndType(label: "About", type: .normal) {
    menuBar.addItem(item: about)
  }
  menuBar.addSeparator()
  if let quit = MenuItem.createWithLabelAndType(label: "Quit", type: .normal) {
    _ = quit.addListener { _ in Application.quit(exitCode: 0) }
    menuBar.addItem(item: quit)
  }
  print("Menu bar installed: \(Application.setMenuBar(menu: menuBar))")
}

// --- 3. Primary window ---
guard let window = Window.create() else {
  fatalError("Failed to create a window")
}
window.setTitle(title: "Swift Application Example")
window.setSize(size: Size(width: 640, height: 480), animate: false)
window.center()

Application.setPrimaryWindow(window: window)
if let primary = Application.getPrimaryWindow() {
  print("Primary window: #\(primary.id)")
}
print("Known windows: \(Application.getAllWindows().count)")

// --- 4. Run ---
if dryRun {
  print("--dry-run: skipping the event loop.")
  print("isRunning = \(Application.isRunning())")
  _ = Application.removeListener(listener)
  exit(0)
}

window.show()
print("Running. Close the window or press Ctrl+C to quit.")
let exitCode = Application.runWithWindow(window: window)
print("Exited with \(exitCode)")
_ = Application.removeListener(listener)
exit(exitCode)
