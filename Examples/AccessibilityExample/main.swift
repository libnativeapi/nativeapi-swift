// Accessibility example — checks whether the process is trusted for
// accessibility APIs, and asks for permission if not.
//
// On macOS enable() opens the System Settings pane; elsewhere it is a no-op
// and isEnabled() reports true.
//
// Usage:
//   swift run AccessibilityExample

import Foundation
import NativeAPI

let enabled = AccessibilityManager.isEnabled()
print("Accessibility enabled: \(enabled)")

if enabled {
  print("Global keyboard monitoring and shortcuts will work.")
  exit(0)
}

print("Requesting accessibility permission...")
AccessibilityManager.enable()
print("After the request: \(AccessibilityManager.isEnabled())")
print(
  "Grant the permission in System Settings > Privacy & Security > Accessibility, "
    + "then run this again.")
