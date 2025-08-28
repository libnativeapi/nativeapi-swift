import CNativeAPI

public class AccessibilityManager {
    public init() {
        // Initialize the accessibility manager
    }

    public func enable() {
        native_accessibility_manager_enable()
    }

    public func isEnabled() -> Bool {
        return native_accessibility_manager_is_enabled()
    }
}
