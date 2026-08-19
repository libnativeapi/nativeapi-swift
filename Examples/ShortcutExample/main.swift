// Shortcut example — registers global shortcuts two ways, inspects them, and
// listens for shortcut events.
//
// Registering a global shortcut needs OS permission on some platforms; the
// example reports failures instead of crashing.
//
// Usage:
//   swift run ShortcutExample

import Foundation
import NativeAPI

// --- 1. Platform support ---
guard ShortcutManager.shared.isSupported() else {
  print("Global shortcuts are not supported on this platform.")
  exit(0)
}

// --- 2. Events ---
let listener = ShortcutManager.shared.addListener { event in
  switch event {
  case .activated(let id, let accelerator):
    print("[shortcut] \(id) activated (\(accelerator ?? "?"))")
  case .registrationFailed(_, let accelerator, let message):
    print("[shortcut] \(accelerator ?? "?") failed: \(message ?? "(no message)")")
  default:
    print("[shortcut] \(event)")
  }
}

// --- 3. Validation, before trying to register ---
for candidate in ["Ctrl+Shift+A", "NotAKey"] {
  let valid = ShortcutManager.shared.isValidAccelerator(accelerator: candidate)
  let available = ShortcutManager.shared.isAvailable(accelerator: candidate)
  print("\(candidate): valid=\(valid) available=\(available)")
}

// --- 4. Register with a bare callback ---
final class Counter {
  var hits = 0
}
let counter = Counter()
let first = ShortcutManager.shared.registerWithAcceleratorAndCallback(accelerator: "Ctrl+Shift+A") {
  counter.hits += 1
  print("Ctrl+Shift+A fired \(counter.hits) time(s)")
}
if let shortcut = first {
  print("Registered #\(shortcut.id) -> \(shortcut.accelerator ?? "?")")
} else {
  print("Could not register Ctrl+Shift+A")
}

// --- 5. Register with full options ---
let options = ShortcutOptions(
  accelerator: "Ctrl+Shift+B",
  callback: { print("Ctrl+Shift+B fired") },
  description: "Second demo shortcut",
  scope: .global,
  enabled: true
)
let second = ShortcutManager.shared.registerWithOptions(options: options)
if let shortcut = second {
  print("Registered #\(shortcut.id) scope=\(shortcut.scope) description=\(shortcut.description ?? "?")")

  // Enable/disable without unregistering.
  shortcut.setEnabled(enabled: false)
  print("Disabled -> isEnabled = \(shortcut.isEnabled)")
  shortcut.setEnabled(enabled: true)

  shortcut.setDescription(description: "Updated description")
  print("Description now \(shortcut.description ?? "?")")

  // Invoking directly is what a test harness would do.
  shortcut.invoke()
}

// --- 6. Enumerate ---
print("All shortcuts: \(ShortcutManager.shared.getAll().count)")
print("Global scope:  \(ShortcutManager.shared.getByScope(scope: .global).count)")
if let found = ShortcutManager.shared.getWithAccelerator(accelerator: "Ctrl+Shift+A") {
  print("Lookup by accelerator -> #\(found.id)")
}
print("Activations so far: \(counter.hits)")

// --- 7. Clean up ---
if let shortcut = first {
  _ = ShortcutManager.shared.unregisterWithId(id: shortcut.id)
}
_ = ShortcutManager.shared.unregisterWithAccelerator(accelerator: "Ctrl+Shift+B")
print("Unregistered \(ShortcutManager.shared.unregisterAll()) remaining shortcut(s)")
_ = ShortcutManager.shared.removeListener(listener)
