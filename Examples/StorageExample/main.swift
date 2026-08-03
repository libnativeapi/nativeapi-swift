// Storage example — writes and reads key/value pairs through Preferences,
// and reports whether SecureStorage is available on this platform.
//
// Usage:
//   swift run StorageExample

import Foundation
import NativeAPI

guard let prefs = Preferences.createWithScope(scope: "com.example.codegen-demo") else {
  fatalError("Failed to create preferences")
}

print("Scope: \(prefs.scope ?? "(none)")")

// --- 1. Write ---
_ = prefs.set(key: "theme", value: "dark")
_ = prefs.set(key: "language", value: "zh-CN")
print("Stored \(prefs.size) item(s)")

// --- 2. Read back ---
print("theme    = \(prefs.get(key: "theme", defaultValue: "") ?? "")")
print("missing  = \(prefs.get(key: "missing", defaultValue: "fallback") ?? "")")
print("contains(language) = \(prefs.contains(key: "language"))")

// --- 3. Containers ---
// On macOS an unscoped read sees the whole user-defaults domain, so print a
// count plus a sample rather than the lot.
let keys = prefs.keys
print("keys returned: \(keys.count) (theme present: \(keys.contains("theme")))")
let all = prefs.all
print("all returned:  \(all.count) entry/entries")
print("all[\"language\"] = \(all["language"] ?? "(missing)")")

// --- 4. Remove ---
_ = prefs.remove(key: "language")
print("After remove: contains(language) = \(prefs.contains(key: "language"))")

// --- 5. Secure storage ---
print("\nSecureStorage available: \(SecureStorage.isAvailable())")
guard SecureStorage.isAvailable(),
  let secure = SecureStorage.createWithScope(scope: "com.example.codegen-demo")
else {
  print("SecureStorage is unavailable on this platform.")
  exit(0)
}
print("SecureStorage scope: \(secure.scope ?? "(none)")")
_ = secure.set(key: "token", value: "s3cr3t")
print("token stored, size = \(secure.size)")
_ = secure.remove(key: "token")
