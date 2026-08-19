// Tray icon example — creates a tray icon with an image and a context menu,
// and listens for clicks.
//
// Usage:
//   swift run TrayIconExample

import Foundation
import NativeAPI

/// A 1x1 transparent PNG, so the example needs no asset on disk.
let pixelPNG = "data:image/png;base64,"
  + "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="

// --- 1. Platform support ---
guard TrayManager.shared.isSupported() else {
  print("System tray is not supported on this platform.")
  exit(0)
}

guard let tray = TrayIcon.create() else {
  fatalError("Failed to create a tray icon")
}
print("Created tray icon #\(tray.getId())")

// --- 2. Events ---
let listener = tray.addListener { event in
  switch event {
  case .clicked(let id): print("[tray] \(id) clicked")
  case .rightClicked(let id): print("[tray] \(id) right-clicked")
  case .doubleClicked(let id): print("[tray] \(id) double-clicked")
  }
}

// --- 3. Appearance ---
tray.setTitle(title: "NativeAPI")
tray.setTooltip(tooltip: "Swift tray icon example")
print("Title: \(tray.getTitle() ?? "(none)")")
print("Tooltip: \(tray.getTooltip() ?? "(none)")")

if let image = Image.fromBase64(base64Data: pixelPNG) {
  print("Icon: \(image.format ?? "?"), size \(image.size.width)x\(image.size.height)")
  tray.setIcon(image: image)
} else {
  print("Could not decode the embedded icon.")
}

// --- 4. Context menu ---
if let menu = Menu.create() {
  for label in ["Show", "Preferences"] {
    if let item = MenuItem.createWithLabelAndType(label: label, type: .normal) {
      menu.addItem(item: item)
    }
  }
  menu.addSeparator()
  if let quit = MenuItem.createWithLabelAndType(label: "Quit", type: .normal) {
    menu.addItem(item: quit)
  }

  tray.setContextMenu(menu: menu)
  tray.setContextMenuTrigger(trigger: .rightClicked)
  print("Trigger: \(tray.getContextMenuTrigger())")
  if let attached = tray.getContextMenu() {
    print("Context menu #\(attached.id) attached")
  }
}

// --- 5. Visibility and geometry ---
let shown = tray.setVisible(visible: true)
print("Visible: \(shown) (isVisible = \(tray.isVisible()))")
let bounds = tray.getBounds()
print("Bounds: (\(bounds.x), \(bounds.y)) \(bounds.width)x\(bounds.height)")

// --- 6. The manager's view ---
print("TrayManager tracks \(TrayManager.shared.getAll().count) icon(s)")
if let same = TrayManager.shared.get(id: tray.getId()) {
  print("Looked up tray icon #\(same.getId()) by id")
}

// --- 7. Clean up ---
_ = tray.removeListener(listener)
_ = tray.setVisible(visible: false)
