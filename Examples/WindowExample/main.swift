// Window example — creates a window, walks through its geometry, style and
// state flags, and subscribes to window events.
//
// The window is never shown: this runs without an event loop so it stays
// useful in a terminal. ApplicationExample shows the loop.
//
// Usage:
//   swift run WindowExample

import Foundation
import NativeAPI

// --- 1. Create ---
guard let window = Window.create() else {
  fatalError("Failed to create a window")
}
print("Created window #\(window.id)")

// --- 2. Events ---
// One listener receives every window event; the payload says which.
let listener = WindowManager.addListener { event in
  switch event {
  case .focused(let windowId): print("[event] window \(windowId) focused")
  case .blurred(let windowId): print("[event] window \(windowId) blurred")
  case .moved(let windowId, let position):
    print("[event] window \(windowId) moved to (\(position.x), \(position.y))")
  case .resized(let windowId, let size):
    print("[event] window \(windowId) resized to \(size.width)x\(size.height)")
  default: print("[event] \(event)")
  }
}
print("Registered window listener #\(listener)")

// --- 3. Title and geometry ---
window.setTitle(title: "Swift Window Example")
print("Title: \(window.title ?? "(none)")")

window.setSize(size: Size(width: 800, height: 600), animate: false)
window.setMinimumSize(size: Size(width: 400, height: 300))
window.setPosition(point: Point(x: 120, y: 80))
window.center()

let bounds = window.bounds
print("Bounds: (\(bounds.x), \(bounds.y)) \(bounds.width)x\(bounds.height)")
let content = window.contentSize
print("Content size: \(content.width)x\(content.height)")

// --- 4. Style ---
window.setTitleBarStyle(style: .hidden)
window.setVisualEffect(effect: .blur)
window.setOpacity(opacity: 0.95)
window.setHasShadow(hasShadow: true)
print("Title bar: \(window.titleBarStyle), effect: \(window.visualEffect), opacity: \(window.opacity)")
let color = window.backgroundColor
print("Background: rgba(\(color.r), \(color.g), \(color.b), \(color.a))")

// --- 5. Capability flags ---
window.setResizable(isResizable: true)
window.setMinimizable(isMinimizable: true)
window.setMaximizable(isMaximizable: false)
window.setAlwaysOnTop(isAlwaysOnTop: true)
print(
  "resizable=\(window.isResizable) minimizable=\(window.isMinimizable) "
    + "maximizable=\(window.isMaximizable) alwaysOnTop=\(window.isAlwaysOnTop)")

// --- 6. State ---
print(
  "visible=\(window.isVisible) focused=\(window.isFocused) "
    + "minimized=\(window.isMinimized) maximized=\(window.isMaximized) "
    + "fullScreen=\(window.isFullScreen)")

// --- 7. The manager's view of things ---
print("WindowManager tracks \(WindowManager.getAll().count) window(s)")
if let current = WindowManager.getCurrent() {
  print("Current window: #\(current.id)")
}
if let same = WindowManager.get(id: window.id) {
  print("Looked up window #\(same.id) by id")
}

// Hooks run before the native show/hide, which is where a UI framework would
// slot its own bookkeeping.
WindowManager.setWillShowHook { id in
  print("[hook] window \(id) is about to be shown")
}
print("hasWillShowHook = \(WindowManager.hasWillShowHook())")
WindowManager.setWillShowHook(hook: nil)

// --- 8. Clean up ---
_ = WindowManager.removeListener(listener)
