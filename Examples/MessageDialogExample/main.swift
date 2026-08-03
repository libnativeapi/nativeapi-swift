// Message dialog example — builds dialogs with each modality and opens them.
//
// open() shows a *modal* dialog and blocks until the user dismisses it, so it
// is opt-in — everything else runs unattended.
//
// Usage:
//   swift run MessageDialogExample
//   swift run MessageDialogExample --open

import Foundation
import NativeAPI

// --- 1. Create ---
guard
  let dialog = MessageDialog.create(
    title: "Update Available",
    message: "A new version is available. Would you like to update?")
else {
  fatalError("Failed to create a message dialog")
}
print("Title:   \(dialog.title ?? "(none)")")
print("Message: \(dialog.message ?? "(none)")")

// --- 2. Update the content before showing it ---
dialog.setTitle(title: "System Update")
dialog.setMessage(message: "Version 2.0 is ready to install.")
print("Retitled to \(dialog.title ?? "(none)")")

// --- 3. Modality ---
for modality in [DialogModality.none, .application, .window] {
  dialog.setModality(modality: modality)
  print("Modality -> \(dialog.modality)")
}

// --- 4. Open and close ---
guard CommandLine.arguments.contains("--open") else {
  print("Pass --open to actually show the dialog (it blocks until dismissed).")
  exit(0)
}
dialog.setModality(modality: .application)
let opened = dialog.open()
print("Opened: \(opened)")
if opened {
  print("Closed: \(dialog.close())")
}
