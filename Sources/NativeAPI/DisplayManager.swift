import CNativeAPI
import Darwin
import Foundation

/// Manages system displays and provides display-related functionality
public class DisplayManager: @unchecked Sendable {
    public static let shared = DisplayManager()

    private init() {}

    /// Get all available displays
    /// - Returns: DisplayList containing all system displays
    public func getAllDisplays() -> DisplayList {
        let cList = native_display_manager_get_all()
        return DisplayList(cList)
    }

    /// Get the primary display
    /// - Returns: The primary display, or nil if no displays are available
    public func getPrimaryDisplay() -> Display? {
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
    public func getDisplay(containing point: Point) -> Display? {
        let displays = getAllDisplays()
        return displays.displays.first { $0.contains(point: point) }
    }

    /// Find display by ID
    /// - Parameter id: The display ID to search for
    /// - Returns: Display with matching ID, or nil if not found
    public func getDisplay(withId id: String) -> Display? {
        let displays = getAllDisplays()
        return displays.display(withId: id)
    }

    /// Get display at the specified index
    /// - Parameter index: The display index
    /// - Returns: Display at the index, or nil if index is out of bounds
    public func getDisplay(at index: Int) -> Display? {
        let displays = getAllDisplays()
        return displays.display(at: index)
    }

    /// Get the display that currently contains the cursor
    /// - Returns: Display containing the cursor, or primary display if cursor is outside all displays
    public func getDisplayUnderCursor() -> Display? {
        let cursorPosition = getCursorPosition()
        return getDisplay(containing: cursorPosition) ?? getPrimaryDisplay()
    }

    /// Get the number of available displays
    /// - Returns: Number of displays in the system
    public var displayCount: Int {
        let displays = getAllDisplays()
        return displays.count
    }

    /// Check if multiple displays are available
    /// - Returns: true if more than one display is available
    public var hasMultipleDisplays: Bool {
        return displayCount > 1
    }

    /// Get total virtual screen bounds (bounding box of all displays)
    /// - Returns: Rectangle encompassing all displays
    public func getVirtualScreenBounds() -> Rectangle {
        let displays = getAllDisplays().displays
        guard !displays.isEmpty else {
            return Rectangle(x: 0, y: 0, width: 0, height: 0)
        }

        var minX = Double.greatestFiniteMagnitude
        var minY = Double.greatestFiniteMagnitude
        var maxX = -Double.greatestFiniteMagnitude
        var maxY = -Double.greatestFiniteMagnitude

        for display in displays {
            let bounds = display.bounds
            minX = min(minX, bounds.x)
            minY = min(minY, bounds.y)
            maxX = max(maxX, bounds.x + bounds.width)
            maxY = max(maxY, bounds.y + bounds.height)
        }

        return Rectangle(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
}

// MARK: - Convenience Methods

extension DisplayManager {
    /// Get all displays sorted by their position (left to right, top to bottom)
    /// - Returns: Array of displays sorted by position
    public func getDisplaysSortedByPosition() -> [Display] {
        let displays = getAllDisplays().displays
        return displays.sorted { (display1, display2) in
            if display1.position.y != display2.position.y {
                return display1.position.y < display2.position.y
            }
            return display1.position.x < display2.position.x
        }
    }

    /// Get all displays sorted by size (largest first)
    /// - Returns: Array of displays sorted by size
    public func getDisplaysSortedBySize() -> [Display] {
        let displays = getAllDisplays().displays
        return displays.sorted { (display1, display2) in
            let area1 = display1.size.width * display1.size.height
            let area2 = display2.size.width * display2.size.height
            return area1 > area2
        }
    }

    /// Get all non-primary displays
    /// - Returns: Array of displays that are not primary
    public func getSecondaryDisplays() -> [Display] {
        let displays = getAllDisplays().displays
        return displays.filter { !$0.isPrimary }
    }

    /// Find displays with specific orientation
    /// - Parameter orientation: The orientation to filter by
    /// - Returns: Array of displays with the specified orientation
    public func getDisplays(withOrientation orientation: DisplayOrientation) -> [Display] {
        let displays = getAllDisplays().displays
        return displays.filter { $0.orientation == orientation }
    }

    /// Find displays with minimum resolution
    /// - Parameters:
    ///   - width: Minimum width in logical pixels
    ///   - height: Minimum height in logical pixels
    /// - Returns: Array of displays meeting the minimum resolution criteria
    public func getDisplays(withMinimumResolution width: Double, height: Double) -> [Display] {
        let displays = getAllDisplays().displays
        return displays.filter { $0.size.width >= width && $0.size.height >= height }
    }

    /// Find displays with specific scale factor
    /// - Parameter scaleFactor: The scale factor to match
    /// - Returns: Array of displays with the specified scale factor
    public func getDisplays(withScaleFactor scaleFactor: Double) -> [Display] {
        let displays = getAllDisplays().displays
        var result: [Display] = []
        for display in displays {
            let difference = display.scaleFactor - scaleFactor
            if (difference < 0 ? -difference : difference) < 0.01 {
                result.append(display)
            }
        }
        return result
    }

    /// Get display statistics
    /// - Returns: Dictionary containing various display statistics
    public func getDisplayStatistics() -> [String: Any] {
        let displays = getAllDisplays().displays

        guard !displays.isEmpty else {
            return [:]
        }

        let totalArea = displays.reduce(0.0) { $0 + ($1.size.width * $1.size.height) }
        let averageWidth = displays.reduce(0.0) { $0 + $1.size.width } / Double(displays.count)
        let averageHeight = displays.reduce(0.0) { $0 + $1.size.height } / Double(displays.count)
        let averageScaleFactor =
            displays.reduce(0.0) { $0 + $1.scaleFactor } / Double(displays.count)

        let landscapeCount = displays.filter { $0.isLandscape }.count
        let portraitCount = displays.filter { $0.isPortrait }.count

        return [
            "totalDisplays": displays.count,
            "primaryDisplays": displays.filter { $0.isPrimary }.count,
            "totalArea": totalArea,
            "averageWidth": averageWidth,
            "averageHeight": averageHeight,
            "averageScaleFactor": averageScaleFactor,
            "landscapeCount": landscapeCount,
            "portraitCount": portraitCount,
            "virtualScreenBounds": getVirtualScreenBounds(),
        ]
    }
}

// MARK: - Window Positioning Helpers

extension DisplayManager {
    /// Find the best display for positioning a window
    /// - Parameters:
    ///   - windowRect: The desired window rectangle
    ///   - preferPrimary: Whether to prefer the primary display
    /// - Returns: The best display for the window, or primary display as fallback
    public func getBestDisplay(for windowRect: Rectangle, preferPrimary: Bool = false) -> Display? {
        if preferPrimary, let primaryDisplay = getPrimaryDisplay() {
            return primaryDisplay
        }

        let displays = getAllDisplays().displays

        // Find display with maximum intersection area
        var bestDisplay: Display?
        var maxIntersectionArea = 0.0

        for display in displays {
            if let intersection = display.intersection(with: windowRect) {
                let intersectionArea = intersection.width * intersection.height
                if intersectionArea > maxIntersectionArea {
                    maxIntersectionArea = intersectionArea
                    bestDisplay = display
                }
            }
        }

        return bestDisplay ?? getPrimaryDisplay()
    }

    /// Center a rectangle on a specific display
    /// - Parameters:
    ///   - size: The size of the rectangle to center
    ///   - display: The display to center on (uses primary if nil)
    /// - Returns: Centered rectangle, or nil if no display is available
    public func centerRect(size: Size, on display: Display? = nil) -> Rectangle? {
        let targetDisplay = display ?? getPrimaryDisplay()
        guard let display = targetDisplay else { return nil }

        let workArea = display.workArea
        let x = workArea.x + (workArea.width - size.width) / 2
        let y = workArea.y + (workArea.height - size.height) / 2

        return Rectangle(x: x, y: y, width: size.width, height: size.height)
    }

    /// Ensure a rectangle is visible on screen (move it if necessary)
    /// - Parameter rect: The rectangle to make visible
    /// - Returns: Adjusted rectangle that is visible on screen
    public func ensureRectangleVisible(_ rect: Rectangle) -> Rectangle {
        let virtualBounds = getVirtualScreenBounds()

        var adjustedRect = rect

        // Ensure the rectangle doesn't go beyond virtual screen bounds
        if adjustedRect.x < virtualBounds.x {
            adjustedRect = Rectangle(
                x: virtualBounds.x,
                y: adjustedRect.y,
                width: adjustedRect.width,
                height: adjustedRect.height
            )
        }

        if adjustedRect.y < virtualBounds.y {
            adjustedRect = Rectangle(
                x: adjustedRect.x,
                y: virtualBounds.y,
                width: adjustedRect.width,
                height: adjustedRect.height
            )
        }

        if adjustedRect.x + adjustedRect.width > virtualBounds.x + virtualBounds.width {
            adjustedRect = Rectangle(
                x: virtualBounds.x + virtualBounds.width - adjustedRect.width,
                y: adjustedRect.y,
                width: adjustedRect.width,
                height: adjustedRect.height
            )
        }

        if adjustedRect.y + adjustedRect.height > virtualBounds.y + virtualBounds.height {
            adjustedRect = Rectangle(
                x: adjustedRect.x,
                y: virtualBounds.y + virtualBounds.height - adjustedRect.height,
                width: adjustedRect.width,
                height: adjustedRect.height
            )
        }

        return adjustedRect
    }
}

// MARK: - Static Convenience Methods

extension DisplayManager {
    /// Quick access to all displays
    /// - Returns: Array of all displays
    public static func getAllDisplays() -> [Display] {
        return DisplayManager.shared.getAllDisplays().displays
    }

    /// Quick access to primary display
    /// - Returns: Primary display, or nil if unavailable
    public static func getPrimaryDisplay() -> Display? {
        return DisplayManager.shared.getPrimaryDisplay()
    }

    /// Quick access to cursor position
    /// - Returns: Current cursor position
    public static func getCursorPosition() -> Point {
        return DisplayManager.shared.getCursorPosition()
    }

    /// Quick access to display count
    /// - Returns: Number of displays
    public static var displayCount: Int {
        return DisplayManager.shared.displayCount
    }

    /// Quick check for multiple displays
    /// - Returns: true if multiple displays are available
    public static var hasMultipleDisplays: Bool {
        return DisplayManager.shared.hasMultipleDisplays
    }
}
