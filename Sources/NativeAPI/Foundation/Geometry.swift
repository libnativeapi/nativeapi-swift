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

/// Represents an offset (similar to Flutter's Offset)
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
