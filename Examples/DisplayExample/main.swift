// Display example — enumerates the connected displays, prints their
// properties, and subscribes to display change events.
//
// Usage:
//   swift run DisplayExample

import Foundation
import NativeAPI

// --- 1. Events ---
let listener = DisplayManager.shared.addListener { event in
  switch event {
  case .added(let display):
    print("[display] added: \(display.name ?? "(unnamed)")")
  case .removed(let display):
    print("[display] removed: \(display.name ?? "(unnamed)")")
  case .changed(_, let oldDisplay, let newDisplay):
    print("[display] changed: \(oldDisplay.name ?? "?") -> \(newDisplay.name ?? "?")")
  }
}

// --- 2. All displays ---
let displays = DisplayManager.shared.getAll()
print("Found \(displays.count) display(s):")
for (index, display) in displays.enumerated() {
  print("\nDisplay \(index + 1):")
  describe(display)
}

// --- 3. Primary ---
if let primary = DisplayManager.shared.getPrimary() {
  print("\nPrimary display: \(primary.name ?? "(unnamed)")")
} else {
  print("\nNo primary display available.")
}

// --- 4. Cursor ---
let cursor = DisplayManager.shared.getCursorPosition()
print("Cursor at (\(cursor.x), \(cursor.y))")

_ = DisplayManager.shared.removeListener(listener)

func describe(_ display: Display) {
  print("  Name:         \(display.name ?? "(unnamed)")")
  print("  Id:           \(display.id ?? "(none)")")
  print("  Position:     (\(display.position.x), \(display.position.y))")
  print("  Size:         \(display.size.width) x \(display.size.height)")
  let area = display.workArea
  print("  Work area:    (\(area.x), \(area.y)) \(area.width) x \(area.height)")
  print("  Scale factor: \(display.scaleFactor)")
  print("  Primary:      \(display.isPrimary)")
  print("  Orientation:  \(display.orientation)")
  print("  Refresh rate: \(display.refreshRate) Hz")
  print("  Bit depth:    \(display.bitDepth)")
}
