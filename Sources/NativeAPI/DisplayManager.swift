import CNativeAPI
import Foundation

/// DisplayManager manages all displays/monitors
public class DisplayManager: @unchecked Sendable {
    /// Singleton instance of DisplayManager
    public static let shared = DisplayManager()

    private init() {}

    /// Returns a list of all displays.
    ///
    /// This method retrieves a list of all available displays using the native
    /// display manager API. It then converts each display handle into a Swift
    /// Display object and returns the list.
    public func getAll() -> [Display] {
        let displayList = native_display_manager_get_all()
        var displays: [Display] = []

        for i in 0..<displayList.count {
            if let nativeHandle = (displayList.displays + i).pointee {
                displays.append(Display(nativeHandle: nativeHandle))
            }
        }

        // Note: In the Dart version, the display list is not freed
        // native_display_list_free(displayList)

        return displays
    }

    /// Returns the current cursor position.
    ///
    /// This method retrieves the current cursor position using the native display
    /// manager API. It then converts the position into a Swift Point object and
    /// returns it.
    public func getCursorPosition() -> Point {
        let nativePoint = native_display_manager_get_cursor_position()
        return Point(nativePoint)
    }

    /// Returns the primary display.
    ///
    /// This method retrieves the primary display using the native display manager
    /// API. It then converts the display handle into a Swift Display object and
    /// returns it.
    public func getPrimary() -> Display? {
        guard let nativeHandle = native_display_manager_get_primary() else {
            return nil
        }
        return Display(nativeHandle: nativeHandle)
    }
}
