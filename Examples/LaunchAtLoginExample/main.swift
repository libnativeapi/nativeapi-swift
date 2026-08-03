// Launch-at-login example — reads the current registration, sets a custom
// program and arguments where the platform allows it, and toggles the state.
//
// Usage:
//   swift run LaunchAtLoginExample

import Foundation
import NativeAPI

// --- 1. Platform support ---
guard LaunchAtLogin.isSupported() else {
  print("Launch at login is not supported on this platform.")
  exit(0)
}

// On macOS the default constructor registers the main app itself; a custom
// identifier is for a bundled login-item helper.
#if os(macOS)
  let created = LaunchAtLogin.create()
#else
  let created = LaunchAtLogin.createWithIdAndDisplayName(
    id: "com.example.swift-demo", displayName: "Swift Demo")
#endif
guard let manager = created else {
  fatalError("Failed to create a LaunchAtLogin manager")
}

// --- 2. Current configuration ---
print("Id:           \(manager.id ?? "(none)")")
print("Display name: \(manager.displayName ?? "(none)")")
print("Executable:   \(manager.executablePath ?? "(none)")")
print("Arguments:    \(manager.arguments)")
print("Enabled:      \(manager.isEnabled)")

// --- 3. Customise ---
_ = manager.setDisplayName(displayName: "Swift Demo (renamed)")
#if !os(macOS)
  // macOS SMAppService cannot take an arbitrary executable or arguments.
  if let executable = manager.executablePath {
    let stored = manager.setProgram(
      executablePath: executable, arguments: ["--minimized", "--from-login"])
    print("setProgram stored locally: \(stored)")
    print("Arguments now: \(manager.arguments)")
  }
#endif

// --- 4. Toggle ---
// Enabling touches the real OS registration, so put it back afterwards.
let wasEnabled = manager.isEnabled
print("Enabling...  \(manager.enable())")
print("Enabled:     \(manager.isEnabled)")
if !wasEnabled {
  print("Restoring... \(manager.disable())")
}
print("Final state: \(manager.isEnabled)")
