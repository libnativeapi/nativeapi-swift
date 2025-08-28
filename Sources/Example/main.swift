import Foundation
import NativeAPI

// MARK: - Simple AppRunner Example

print("=== NativeAPI AppRunner Simple Example ===")
print("🚀 This demonstrates the simplest way to use AppRunner")
print()

// Method 1: Using the convenience function with default window
print("📱 Method 1: Running app with default window")
print("💡 This creates a default window and runs the application")
print()

// Uncomment to try the simplest approach:
// let exitCode = runApp()
// print("✅ App exited with code: \(exitCode)")

// Method 2: Using custom window options
print("📱 Method 2: Running app with custom window options")
print("💡 This creates a window with specific options")
print()

// Create custom window options
let options = WindowOptions()
_ = options.setTitle("My Swift App")
options.setSize(Size(width: 1000, height: 700))
options.setMinimumSize(Size(width: 500, height: 350))
options.setCentered(true)

print("⚙️ Window options configured:")
print("   - Title: 'My Swift App'")
print("   - Size: 1000x700")
print("   - Minimum size: 500x350")
print("   - Centered on screen")
print()

// Run with custom options
let exitCodeWithOptions = runApp(with: options)
print("✅ App exited with code: \(exitCodeWithOptions)")

print()
print("🎉 Simple AppRunner example completed!")
print("📝 This example showed:")
print("   ✅ Simple one-line app launching")
print("   ✅ Custom window configuration")
print("   ✅ Exit code handling")
print()
print("💡 For more advanced features, see AppRunnerExample.swift")
