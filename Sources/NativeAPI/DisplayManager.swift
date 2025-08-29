import CNativeAPI
import Darwin
import Foundation

/// Manages system displays and provides display-related functionality
public class DisplayManager: @unchecked Sendable {
    public static let shared = DisplayManager()

    private init() {}

    /// Get all available displays
    /// - Returns: Array of Display objects containing all system displays
    public func getAll() -> [Display] {
        let cList = native_display_manager_get_all()
        var result: [Display] = []
        for i in 0..<cList.count {
            let cDisplay = cList.displays.advanced(by: i).pointee
            result.append(Display(cDisplay))
        }
        return result
    }

    /// Get the primary display
    /// - Returns: The primary display, or nil if no displays are available
    public func getPrimary() -> Display? {
        let cDisplay = native_display_manager_get_primary()
        // Check if we got a valid display (assuming id is not null for valid displays)
        guard cDisplay.id != nil else { return nil }
        return Display(cDisplay)
    }

    /// Get the current cursor position in screen coordinates
    /// - Returns: Current cursor position as a Point
    public func getCursorPosition() -> Point {
        let cPoint = native_display_manager_get_cursor_position()
        return Point(cPoint)
    }

    /// Find display containing the specified point
    /// - Parameter point: The point to search for
    /// - Returns: Display containing the point, or nil if no display contains the point
    public func get(containing point: Point) -> Display? {
        let displays = getAll()
        return displays.first { $0.contains(point: point) }
    }

    /// Find display by ID
    /// - Parameter id: The display ID to search for
    /// - Returns: Display with matching ID, or nil if not found
    public func get(withId id: String) -> Display? {
        let displays = getAll()
        return displays.first { $0.id == id }
    }

}
