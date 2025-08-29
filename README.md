# NativeAPI Swift

A Swift package providing native desktop application APIs with cross-platform window management, application lifecycle control, and system integration features.

## Features

- **AppRunner**: Application lifecycle management and event loop integration
- **Window Management**: Create, configure, and control native windows
- **Display Management**: Multi-display support and screen information
- **System Integration**: Tray icons, keyboard monitoring, and accessibility features
- **Cross-Platform**: Support for macOS, with planned support for Windows and Linux

## Quick Start

### Simple Application

Create a basic native application with just a few lines of code:

```swift
import NativeAPI

// Run with default window
let exitCode = runApp()
print("App exited with code: \(exitCode)")
```

### Custom Window Application

```swift
import NativeAPI

// Configure window options
let options = WindowOptions()
_ = options.setTitle("My Swift App")
options.setSize(Size(width: 1000, height: 700))
options.setMinimumSize(Size(width: 500, height: 350))
options.setCentered(true)

// Run with custom options
let exitCode = runApp(with: options)
print("App exited with code: \(exitCode)")
```

### Advanced Application

```swift
import Foundation
import NativeAPI

@MainActor
class MyApplication {
    private var mainWindow: Window?
    
    func initialize() -> Bool {
        return WindowManager.shared.initialize()
    }
    
    func setupWindow() -> Bool {
        let options = WindowOptions()
        _ = options.setTitle("Advanced App")
        options.setSize(Size(width: 1200, height: 800))
        
        guard let window = WindowManager.shared.createWindow(with: options) else {
            return false
        }
        
        self.mainWindow = window
        return true
    }
    
    func run() -> AppExitCode {
        guard let window = mainWindow else {
            return .invalidWindow
        }
        
        window.show()
        return AppRunner.shared.run(with: window)
    }
}

let app = MyApplication()
guard app.initialize() && app.setupWindow() else {
    exit(1)
}

let exitCode = app.run()
exit(exitCode.rawValue)
```

## Installation

### Swift Package Manager

Add this package to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/leanflutter/nativeapi-swift", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version and add to your target

## Core Components

### AppRunner

Manages application lifecycle and runs the native event loop:

```swift
// Singleton access
let appRunner = AppRunner.shared

// Check if running
if appRunner.isRunning {
    print("Application is currently running")
}

// Run with window
let exitCode = appRunner.run(with: window)
```

**Exit Codes:**
- `.success` (0) - Normal exit
- `.failure` (1) - Application error
- `.invalidWindow` (2) - Invalid window provided

### Window Management

Create and control native windows:

```swift
// Create window with options
let options = WindowOptions()
_ = options.setTitle("My Window")
options.setSize(Size(width: 800, height: 600))

let window = WindowManager.shared.createWindow(with: options)

// Window operations
window?.show()
window?.hide()
window?.minimize()
window?.maximize()
window?.focus()

// Window properties
window?.title = "New Title"
window?.size = Size(width: 1000, height: 800)
window?.position = Point(x: 100, y: 100)
window?.opacity = 0.9
window?.isAlwaysOnTop = true
```

### Event Handling

Monitor window events:

```swift
let callbackId = WindowManager.shared.registerEventCallback { event in
    switch event.type {
    case .created:
        print("Window created")
    case .closed:
        print("Window closed")
    case .focused:
        print("Window focused")
    case .moved(let position):
        print("Window moved to \(position)")
    case .resized(let size):
        print("Window resized to \(size)")
    }
}

// Don't forget to unregister
_ = WindowManager.shared.unregisterEventCallback(callbackId)
```

### Display Management

Work with multiple displays:

```swift
let displayManager = DisplayManager.shared
let displays = displayManager.getAllDisplays()

for display in displays.displays {
    print("Display: \(display.name)")
    print("Resolution: \(display.size.width)x\(display.size.height)")
    print("Scale: \(display.scaleFactor)")
}

// Get primary display
if let primary = displayManager.getPrimaryDisplay() {
    print("Primary display: \(primary.name)")
}
```

## Platform Support

### macOS

Full support with native Cocoa integration:

```swift
#if os(macOS)
// Access native NSWindow
if let nsWindow = window.nsWindow {
    // Perform macOS-specific operations
}
#endif
```

### Windows & Linux

Planned support for future releases.

## Examples

The package includes comprehensive examples:

- **Basic Example** (`Sources/Example/main.swift`): Simple usage patterns
- **Advanced Example** (`Sources/Example/AppRunnerExample.swift`): Full application with event handling

Run examples:

```bash
swift run Example
```

## Testing

Run the test suite:

```bash
# Run all tests
swift test

# Run specific tests
swift test --filter AppRunnerTests
swift test --filter WindowManagerTests
```

## Documentation

Detailed documentation is available:

- [AppRunner Bindings](APP_RUNNER_BINDINGS.md) - Application lifecycle management
- [Window Bindings](WINDOW_BINDINGS.md) - Window management APIs

## Requirements

- **macOS**: 10.15 or later
- **Swift**: 6.0 or later
- **Xcode**: 16.0 or later (for development)

## Architecture

The package consists of:

1. **C++ Core Library** (`libnativeapi`): Cross-platform native implementations
2. **C API Layer** (`capi`): C interface for Swift interoperability  
3. **Swift Bindings**: High-level Swift APIs wrapping the C interface

```
Swift Application
       ↓
Swift Bindings (NativeAPI)
       ↓
C API Layer (CNativeAPI)
       ↓
C++ Core Library (libnativeapi)
       ↓
Platform APIs (Cocoa, Win32, X11)
```

## Best Practices

### Resource Management

Always initialize and cleanup properly:

```swift
// Initialize
guard WindowManager.shared.initialize() else {
    exit(1)
}

// Use resources...

// Cleanup
defer {
    WindowManager.shared.shutdown()
}
```

### Thread Safety

UI operations should be performed on the main thread:

```swift
@MainActor
class UIManager {
    func updateWindow() {
        // Safe to call UI methods here
        window.show()
    }
}

// Or use DispatchQueue when needed
DispatchQueue.main.async {
    window.title = "Updated Title"
}
```

### Error Handling

Handle failures gracefully:

```swift
guard let window = WindowManager.shared.createWindow(with: options) else {
    print("Failed to create window")
    return .failure
}

let exitCode = AppRunner.shared.run(with: window)
if exitCode != .success {
    print("Application exited with error: \(exitCode)")
}
```

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Update documentation
5. Submit a pull request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/leanflutter/nativeapi-swift
cd nativeapi-swift

# Build the project
swift build

# Run tests
swift test

# Run examples
swift run Example
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Related Projects

- [nativeapi](https://github.com/leanflutter/nativeapi) - Core C++ library
- [nativeapi-dart](https://github.com/leanflutter/nativeapi-dart) - Dart bindings

## Support

- [Issues](https://github.com/leanflutter/nativeapi-swift/issues) - Bug reports and feature requests
- [Discussions](https://github.com/leanflutter/nativeapi-swift/discussions) - Questions and community support
- [Documentation](https://github.com/leanflutter/nativeapi-swift/wiki) - Detailed guides and tutorials