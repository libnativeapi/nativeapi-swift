import CNativeAPI
import Foundation

/// Application manages the application lifecycle and event loop
public class Application: @unchecked Sendable {
    /// Shared singleton instance
    public static let shared = Application()
    
    private let nativeHandle: native_application_t
    
    private init() {
        nativeHandle = native_application_get_instance()
    }
    
    /// Run the application main event loop
    /// This method starts the main event loop and blocks until the application exits
    /// - Returns: Exit code of the application (0 for success)
    public func run() -> Int32 {
        return Int32(native_application_run(nativeHandle))
    }
    
    /// Run the application with the specified window
    /// - Parameter window: The window to run the application with
    /// - Returns: Exit code of the application (0 for success)
    public func run(with window: Window) -> Int32 {
        return Int32(native_application_run_with_window(nativeHandle, window.handle))
    }
    
    /// Request the application to quit
    /// - Parameter exitCode: The exit code to use when quitting (default: 0)
    public func quit(exitCode: Int32 = 0) {
        native_application_quit(nativeHandle, exitCode)
    }
    
    /// Check if the application is currently running
    /// - Returns: true if the app is running, false otherwise
    public var isRunning: Bool {
        return native_application_is_running(nativeHandle)
    }
    
    /// Check if this is a single instance application
    /// - Returns: true if only one instance is allowed, false otherwise
    public var isSingleInstance: Bool {
        return native_application_is_single_instance(nativeHandle)
    }
    
    /// Set the application icon
    /// - Parameter iconPath: Path to the icon file
    /// - Returns: true if the icon was set successfully, false otherwise
    public func setIcon(_ iconPath: String) -> Bool {
        return native_application_set_icon(nativeHandle, iconPath)
    }
    
    /// Show or hide the dock icon (macOS only)
    /// - Parameter visible: true to show the dock icon, false to hide it
    /// - Returns: true if the operation succeeded, false otherwise
    public func setDockIconVisible(_ visible: Bool) -> Bool {
        return native_application_set_dock_icon_visible(nativeHandle, visible)
    }
}

/// Convenience function to run the application with the specified window
/// This is equivalent to calling Application.shared.run(with: window)
/// - Parameter window: The window to run the application with
/// - Returns: Exit code of the application (0 for success)
public func runApp(with window: Window) -> Int32 {
    return Application.shared.run(with: window)
}

/// Convenience function to run the application without a window
/// - Returns: Exit code of the application (0 for success)
public func runApp() -> Int32 {
    return Application.shared.run()
}

