import CNativeAPI
import Foundation

/// Display orientation enumeration
public enum DisplayOrientation: Int {
    case portrait = 0
    case landscape = 90
    case portraitFlipped = 180
    case landscapeFlipped = 270

    internal init(_ cOrientation: native_display_orientation_t) {
        switch cOrientation {
        case NATIVE_DISPLAY_ORIENTATION_PORTRAIT:
            self = .portrait
        case NATIVE_DISPLAY_ORIENTATION_LANDSCAPE:
            self = .landscape
        case NATIVE_DISPLAY_ORIENTATION_PORTRAIT_FLIPPED:
            self = .portraitFlipped
        case NATIVE_DISPLAY_ORIENTATION_LANDSCAPE_FLIPPED:
            self = .landscapeFlipped
        default:
            self = .portrait
        }
    }

    internal var cValue: native_display_orientation_t {
        switch self {
        case .portrait:
            return NATIVE_DISPLAY_ORIENTATION_PORTRAIT
        case .landscape:
            return NATIVE_DISPLAY_ORIENTATION_LANDSCAPE
        case .portraitFlipped:
            return NATIVE_DISPLAY_ORIENTATION_PORTRAIT_FLIPPED
        case .landscapeFlipped:
            return NATIVE_DISPLAY_ORIENTATION_LANDSCAPE_FLIPPED
        }
    }
}

/// Represents a display/monitor with all its properties
public class Display: @unchecked Sendable {
    internal let cDisplay: native_display_t

    /// Unique identifier for the display
    public var id: String {
        guard let idPtr = cDisplay.id else {
            return "unknown"
        }
        return String(cString: idPtr)
    }

    /// Human-readable display name
    public var name: String {
        guard let namePtr = cDisplay.name else {
            return "Unknown Display"
        }
        return String(cString: namePtr)
    }

    /// Display position in virtual desktop coordinates
    public var position: Point {
        return Point(cDisplay.position)
    }

    /// Full display size in logical pixels
    public var size: Size {
        return Size(cDisplay.size)
    }

    /// Available work area (excluding taskbars, docks, etc.)
    public var workArea: Rectangle {
        return Rectangle(cDisplay.work_area)
    }

    /// Display scaling factor (1.0 = 100%, 2.0 = 200%, etc.)
    public var scaleFactor: Double {
        return cDisplay.scale_factor
    }

    /// Whether this is the primary display
    public var isPrimary: Bool {
        return cDisplay.is_primary
    }

    /// Current display orientation
    public var orientation: DisplayOrientation {
        return DisplayOrientation(cDisplay.orientation)
    }

    /// Refresh rate in Hz (0 if unknown)
    public var refreshRate: Int {
        return Int(cDisplay.refresh_rate)
    }

    /// Color bit depth (0 if unknown)
    public var bitDepth: Int {
        return Int(cDisplay.bit_depth)
    }

    /// Display manufacturer
    public var manufacturer: String? {
        guard let manufacturerPtr = cDisplay.manufacturer else { return nil }
        return String(cString: manufacturerPtr)
    }

    /// Display model
    public var model: String? {
        guard let modelPtr = cDisplay.model else { return nil }
        return String(cString: modelPtr)
    }

    /// Display serial number (if available)
    public var serialNumber: String? {
        guard let serialPtr = cDisplay.serial_number else { return nil }
        return String(cString: serialPtr)
    }

    internal init(_ cDisplay: native_display_t) {
        self.cDisplay = cDisplay
    }

    deinit {
        // The C API should handle cleanup when the display list is freed
    }
}

// MARK: - Display List

/// Represents a list of displays
public class DisplayList: @unchecked Sendable {
    private let cList: native_display_list_t
    private let shouldFreeCList: Bool

    /// Number of displays in the list
    public var count: Int {
        return Int(cList.count)
    }

    /// All displays as an array
    public var displays: [Display] {
        var result: [Display] = []
        for i in 0..<count {
            let cDisplay = cList.displays.advanced(by: i).pointee
            result.append(Display(cDisplay))
        }
        return result
    }

    internal init(_ cList: native_display_list_t, shouldFreeCList: Bool = true) {
        self.cList = cList
        self.shouldFreeCList = shouldFreeCList
    }

    deinit {
        if shouldFreeCList {
            var mutableList = cList
            native_display_list_free(&mutableList)
        }
    }

    /// Get display at specified index
    /// - Parameter index: The index of the display
    /// - Returns: Display at the specified index, or nil if index is out of bounds
    public func display(at index: Int) -> Display? {
        guard index >= 0 && index < count else { return nil }
        let cDisplay = cList.displays.advanced(by: index).pointee
        return Display(cDisplay)
    }

    /// Find display by ID
    /// - Parameter id: The display ID to search for
    /// - Returns: Display with matching ID, or nil if not found
    public func display(withId id: String) -> Display? {
        return displays.first { $0.id == id }
    }

    /// Find the primary display
    /// - Returns: Primary display, or nil if none found
    public var primaryDisplay: Display? {
        return displays.first { $0.isPrimary }
    }
}

// MARK: - Display Extensions

extension Display: CustomStringConvertible {
    public var description: String {
        return
            "Display(id: \(id), name: \(name), size: \(size.width)x\(size.height), isPrimary: \(isPrimary))"
    }
}

extension Display: Equatable {
    public static func == (lhs: Display, rhs: Display) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Display: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Convenience Properties

extension Display {
    /// Display bounds as a rectangle
    public var bounds: Rectangle {
        return Rectangle(x: position.x, y: position.y, width: size.width, height: size.height)
    }

    /// Work area as a point and size
    public var workAreaBounds: Rectangle {
        return workArea
    }

    /// Check if the display is in landscape orientation
    public var isLandscape: Bool {
        return orientation == .landscape || orientation == .landscapeFlipped
    }

    /// Check if the display is in portrait orientation
    public var isPortrait: Bool {
        return orientation == .portrait || orientation == .portraitFlipped
    }

    /// Display aspect ratio (width / height)
    public var aspectRatio: Double {
        guard size.height > 0 else { return 1.0 }
        return size.width / size.height
    }

    /// Display resolution in pixels (considering scale factor)
    public var pixelSize: Size {
        return Size(width: size.width * scaleFactor, height: size.height * scaleFactor)
    }

    /// Display density (pixels per inch) - estimated based on common display sizes
    public var estimatedDPI: Double {
        // This is a rough estimation - actual DPI would need platform-specific APIs
        let diagonalPixels = sqrt(pow(pixelSize.width, 2) + pow(pixelSize.height, 2))
        let diagonalInches = sqrt(pow(size.width / 96.0, 2) + pow(size.height / 96.0, 2))  // Assuming 96 DPI base
        return diagonalPixels / diagonalInches
    }
}

// MARK: - Utility Methods

extension Display {
    /// Check if a point is within this display's bounds
    /// - Parameter point: The point to check
    /// - Returns: true if the point is within the display bounds
    public func contains(point: Point) -> Bool {
        return point.x >= position.x && point.x < position.x + size.width && point.y >= position.y
            && point.y < position.y + size.height
    }

    /// Check if a rectangle intersects with this display's bounds
    /// - Parameter rect: The rectangle to check
    /// - Returns: true if the rectangle intersects with the display bounds
    public func intersects(with rect: Rectangle) -> Bool {
        let displayRight = position.x + size.width
        let displayBottom = position.y + size.height
        let rectRight = rect.x + rect.width
        let rectBottom = rect.y + rect.height

        return
            !(rect.x >= displayRight || rectRight <= position.x || rect.y >= displayBottom
            || rectBottom <= position.y)
    }

    /// Get the intersection area with a rectangle
    /// - Parameter rect: The rectangle to intersect with
    /// - Returns: The intersection rectangle, or nil if no intersection
    public func intersection(with rect: Rectangle) -> Rectangle? {
        let displayRight = position.x + size.width
        let displayBottom = position.y + size.height
        let rectRight = rect.x + rect.width
        let rectBottom = rect.y + rect.height

        let left = max(position.x, rect.x)
        let top = max(position.y, rect.y)
        let right = min(displayRight, rectRight)
        let bottom = min(displayBottom, rectBottom)

        guard left < right && top < bottom else { return nil }

        return Rectangle(x: left, y: top, width: right - left, height: bottom - top)
    }
}
