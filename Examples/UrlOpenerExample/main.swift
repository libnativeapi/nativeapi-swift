// UrlOpener example — checks support and opens a URL with the system handler.
//
// Usage:
//   swift run UrlOpenerExample
//   swift run UrlOpenerExample "https://www.example.com"

import Foundation
import NativeAPI

// --- 1. Check support ---
let supported = UrlOpener.shared.isSupported()
print("URL opening supported: \(supported)")
guard supported else {
  FileHandle.standardError.write("URL opening is not supported on this platform.\n".data(using: .utf8)!)
  exit(1)
}

// --- 2. Pick a URL ---
let url = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "https://www.swift.org"

// --- 3. Can it be opened? ---
print("canOpen(\(url)) = \(UrlOpener.shared.canOpen(url: url))")

// --- 4. Open it ---
print("Opening \(url) ...")
let result = UrlOpener.shared.open(url: url)
if result.success {
  print("URL opened successfully.")
} else {
  print("Failed: \(result.errorCode) - \(result.errorMessage ?? "(no message)")")
  exit(1)
}
