// Keyboard example — starts a keyboard monitor and prints key and modifier
// events for a few seconds.
//
// Monitoring the keyboard globally needs accessibility permission on macOS;
// without it the monitor simply reports that it is not running.
//
// Usage:
//   swift run KeyboardExample

import Foundation
import NativeAPI

guard let monitor = KeyboardMonitor.create() else {
  fatalError("Failed to create a keyboard monitor")
}

/// The modifier mask is a bit set of `ModifierKey` values.
func describe(_ mask: UInt32) -> String {
  let flags: [(ModifierKey, String)] = [
    (.shift, "Shift"), (.ctrl, "Ctrl"), (.alt, "Alt"), (.meta, "Meta"),
    (.fn, "Fn"), (.capsLock, "CapsLock"), (.numLock, "NumLock"), (.scrollLock, "ScrollLock"),
  ]
  let names = flags.filter { mask & UInt32($0.0.rawValue) != 0 }.map(\.1)
  return names.isEmpty ? "none" : names.joined(separator: " + ")
}

// --- 1. Events ---
let listener = monitor.addListener { event in
  switch event {
  case .keyPressed(let keycode): print("[key] pressed  \(keycode)")
  case .keyReleased(let keycode): print("[key] released \(keycode)")
  case .modifierKeysChanged(_, let modifiers):
    print("[key] modifiers \(String(format: "%#06x", modifiers)) -> \(describe(modifiers))")
  }
}

// --- 2. Start ---
monitor.start()
if monitor.isMonitoring {
  print("Monitoring for 5 seconds — press some keys.")
  RunLoop.current.run(until: Date().addingTimeInterval(5))
} else {
  print("Monitor did not start. This is expected without accessibility permission.")
}

// --- 3. Stop ---
monitor.stop()
print("isMonitoring = \(monitor.isMonitoring)")
_ = monitor.removeListener(listener)
