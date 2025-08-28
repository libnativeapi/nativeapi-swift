import Foundation
import NativeAPI

// MARK: - Main Program

print("=== NativeAPI Swift Example ===")
print()

// Test basic Display functionality
print("🚀 Testing NativeAPI Display...")

let accessibilityManager = AccessibilityManager()

accessibilityManager.enable()

let isAccessibilityEnabled = accessibilityManager.isEnabled()

print("✅ Accessibility is enabled:", isAccessibilityEnabled)

let display = Display()
print("✅ Display instance created successfully!")
print()

print("📱 NativeAPI is working correctly!")
print("💡 This example demonstrates that the NativeAPI library can be imported and used.")
print()

print("🎯 Next steps:")
print("   - Implement more functionality in the NativeAPI module")
print("   - Add real display management features")
print("   - Test with actual display operations")
print()

print("✅ Example completed successfully!")
