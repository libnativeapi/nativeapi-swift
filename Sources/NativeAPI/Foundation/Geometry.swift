import Foundation
import CNativeAPI

/// Represents a point with x and y coordinates
public struct Point: Equatable, Hashable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    internal init(_ cPoint: native_point_t) {
        self.x = cPoint.x
        self.y = cPoint.y
    }

    internal var cStruct: native_point_t {
        return native_point_t(x: x, y: y)
    }
}

/// Represents a size with width and height
public struct Size: Equatable, Hashable, Sendable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    /// Zero size
    public static let zero = Size(width: 0, height: 0)

    internal init(_ cSize: native_size_t) {
        self.width = cSize.width
        self.height = cSize.height
    }

    internal var cStruct: native_size_t {
        return native_size_t(width: width, height: height)
    }
}

/// Represents a rectangle with position and size
public struct Rect: Equatable, Hashable, Sendable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    /// Create a rectangle from left, top, width, height
    public static func fromLTWH(left: Double, top: Double, width: Double, height: Double) -> Rect {
        return Rect(x: left, y: top, width: width, height: height)
    }

    internal init(_ cRect: native_rectangle_t) {
        self.x = cRect.x
        self.y = cRect.y
        self.width = cRect.width
        self.height = cRect.height
    }

    internal var cStruct: native_rectangle_t {
        return native_rectangle_t(x: x, y: y, width: width, height: height)
    }
    
    /// The left edge of the rectangle
    public var left: Double { x }
    
    /// The top edge of the rectangle
    public var top: Double { y }
    
    /// The right edge of the rectangle
    public var right: Double { x + width }
    
    /// The bottom edge of the rectangle
    public var bottom: Double { y + height }
    
    /// The center point of the rectangle
    public var center: Point {
        Point(x: x + width / 2, y: y + height / 2)
    }
}

/// Represents an offset with dx and dy components
public struct Offset: Equatable, Hashable, Sendable {
    public let dx: Double
    public let dy: Double
    
    public init(dx: Double, dy: Double) {
        self.dx = dx
        self.dy = dy
    }
    
    /// Zero offset
    public static let zero = Offset(dx: 0, dy: 0)
    
    /// Convert to Point
    public var point: Point {
        Point(x: dx, y: dy)
    }
}

/// Placement options for positioning UI elements relative to an anchor.
///
/// Placement defines how a UI element (such as a menu or popover) should be
/// positioned relative to a reference point or rectangle.
///
/// Example:
/// ```swift
/// // Position menu below the anchor, horizontally centered
/// menu.open(strategy, placement: .bottom)
///
/// // Position menu below the anchor, aligned to the left
/// menu.open(strategy, placement: .bottomStart)
///
/// // Position menu above the anchor, aligned to the right
/// menu.open(strategy, placement: .topEnd)
/// ```
public enum Placement: Int32, CaseIterable {
    /// Position above the anchor, horizontally centered.
    case top = 0
    
    /// Position above the anchor, aligned to the start (left).
    case topStart = 1
    
    /// Position above the anchor, aligned to the end (right).
    case topEnd = 2
    
    /// Position to the right of the anchor, vertically centered.
    case right = 3
    
    /// Position to the right of the anchor, aligned to the start (top).
    case rightStart = 4
    
    /// Position to the right of the anchor, aligned to the end (bottom).
    case rightEnd = 5
    
    /// Position below the anchor, horizontally centered.
    case bottom = 6
    
    /// Position below the anchor, aligned to the start (left).
    case bottomStart = 7
    
    /// Position below the anchor, aligned to the end (right).
    case bottomEnd = 8
    
    /// Position to the left of the anchor, vertically centered.
    case left = 9
    
    /// Position to the left of the anchor, aligned to the start (top).
    case leftStart = 10
    
    /// Position to the left of the anchor, aligned to the end (bottom).
    case leftEnd = 11
    
    internal var nativeValue: native_placement_t {
        switch self {
        case .top: return NATIVE_PLACEMENT_TOP
        case .topStart: return NATIVE_PLACEMENT_TOP_START
        case .topEnd: return NATIVE_PLACEMENT_TOP_END
        case .right: return NATIVE_PLACEMENT_RIGHT
        case .rightStart: return NATIVE_PLACEMENT_RIGHT_START
        case .rightEnd: return NATIVE_PLACEMENT_RIGHT_END
        case .bottom: return NATIVE_PLACEMENT_BOTTOM
        case .bottomStart: return NATIVE_PLACEMENT_BOTTOM_START
        case .bottomEnd: return NATIVE_PLACEMENT_BOTTOM_END
        case .left: return NATIVE_PLACEMENT_LEFT
        case .leftStart: return NATIVE_PLACEMENT_LEFT_START
        case .leftEnd: return NATIVE_PLACEMENT_LEFT_END
        }
    }
    
    internal init(nativeValue: native_placement_t) {
        switch nativeValue {
        case NATIVE_PLACEMENT_TOP: self = .top
        case NATIVE_PLACEMENT_TOP_START: self = .topStart
        case NATIVE_PLACEMENT_TOP_END: self = .topEnd
        case NATIVE_PLACEMENT_RIGHT: self = .right
        case NATIVE_PLACEMENT_RIGHT_START: self = .rightStart
        case NATIVE_PLACEMENT_RIGHT_END: self = .rightEnd
        case NATIVE_PLACEMENT_BOTTOM: self = .bottom
        case NATIVE_PLACEMENT_BOTTOM_START: self = .bottomStart
        case NATIVE_PLACEMENT_BOTTOM_END: self = .bottomEnd
        case NATIVE_PLACEMENT_LEFT: self = .left
        case NATIVE_PLACEMENT_LEFT_START: self = .leftStart
        case NATIVE_PLACEMENT_LEFT_END: self = .leftEnd
        default: self = .bottomStart
        }
    }
}
