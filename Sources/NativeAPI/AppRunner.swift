import CNativeAPI
import Foundation

/// AppRunner exit codes
public enum AppExitCode: Int32 {
    case success = 0
    case failure = 1
    case invalidWindow = 2
}

/// AppRunner manages the application lifecycle and event loop
public class AppRunner: @unchecked Sendable {
    /// Shared singleton instance
    public static let shared = AppRunner()

    private init() {}

    /// Run the application with the specified window
    /// This method starts the main event loop and blocks until the application exits
    /// - Parameter window: The window to run the application with
    /// - Returns: Exit code of the application (0 for success)
    public func run(with window: Window) -> AppExitCode {
        let exitCode = native_app_runner_run(window.handle)
        return AppExitCode(rawValue: exitCode) ?? .failure
    }

    /// Check if the application is currently running
    /// - Returns: true if the app is running, false otherwise
    public var isRunning: Bool {
        return native_app_runner_is_running()
    }
}

/// Convenience function to run the application with the specified window
/// This is equivalent to calling AppRunner.shared.run(with: window)
/// - Parameter window: The window to run the application with
/// - Returns: Exit code of the application (0 for success)
public func runApp(with window: Window) -> AppExitCode {
    return AppRunner.shared.run(with: window)
}

/// Convenience function to run the application with window options
/// Creates a window with the specified options and runs the application
/// - Parameter options: Window options for creating the window
/// - Returns: Exit code of the application (0 for success)
public func runApp(with options: WindowOptions) -> AppExitCode {
    guard let window = WindowManager.shared.create(with: options) else {
        return .invalidWindow
    }
    return AppRunner.shared.run(with: window)
}

/// Convenience function to run the application with default window
/// Creates a default window and runs the application
/// - Returns: Exit code of the application (0 for success)
public func runApp() -> AppExitCode {
    guard let window = WindowManager.shared.create() else {
        return .invalidWindow
    }
    return AppRunner.shared.run(with: window)
}
