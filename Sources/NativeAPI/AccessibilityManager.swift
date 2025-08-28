import CNativeAPI

public class AccessibilityManager: @unchecked Sendable {
    public static let shared = AccessibilityManager()

    private init() {}

    public func enable() {
        native_accessibility_manager_enable()
    }

    public func isEnabled() -> Bool {
        return native_accessibility_manager_is_enabled()
    }
}
