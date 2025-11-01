import Foundation
import CNativeAPI

/// Strategy for determining where to position UI elements.
///
/// PositioningStrategy defines how to calculate the position for UI elements
/// such as menus, tooltips, or popovers. It supports various positioning modes:
/// - Absolute: Fixed screen coordinates
/// - CursorPosition: Current mouse cursor position
/// - Relative: Position relative to a rectangle
///
/// Example:
/// ```swift
/// // Position menu at absolute screen coordinates
/// menu.open(PositioningStrategy.absolute(Point(x: 100, y: 200)), placement: .bottom)
///
/// // Position menu at current mouse location
/// menu.open(PositioningStrategy.cursorPosition(), placement: .bottomStart)
///
/// // Position menu relative to a rectangle with offset
/// let buttonRect = button.bounds
/// menu.open(PositioningStrategy.relative(rect: buttonRect, offset: Point(x: 0, y: 10)), placement: .bottom)
/// ```
public struct PositioningStrategy {
    /// Type of positioning strategy
    public enum StrategyType: Int32 {
        /// Position at fixed screen coordinates
        case absolute = 0
        /// Position at current mouse cursor location
        case cursorPosition = 1
        /// Position relative to a rectangle
        case relative = 2
    }
    
    internal let type: StrategyType
    internal let absolutePosition: Point?
    internal let relativeRect: Rect?
    internal let relativeOffset: Point?
    internal let relativeWindow: Window?
    
    private init(type: StrategyType, absolutePosition: Point? = nil, relativeRect: Rect? = nil, relativeOffset: Point? = nil, relativeWindow: Window? = nil) {
        self.type = type
        self.absolutePosition = absolutePosition
        self.relativeRect = relativeRect
        self.relativeOffset = relativeOffset
        self.relativeWindow = relativeWindow
    }
    
    /// Create a strategy for absolute positioning at fixed coordinates.
    ///
    /// - Parameter point: Point in screen coordinates
    /// - Returns: PositioningStrategy configured for absolute positioning
    ///
    /// Example:
    /// ```swift
    /// let strategy = PositioningStrategy.absolute(Point(x: 100, y: 200))
    /// menu.open(strategy, placement: .bottom)
    /// ```
    public static func absolute(_ point: Point) -> PositioningStrategy {
        return PositioningStrategy(type: .absolute, absolutePosition: point)
    }
    
    /// Create a strategy for positioning at current mouse location.
    ///
    /// - Returns: PositioningStrategy configured to use mouse cursor position
    ///
    /// Example:
    /// ```swift
    /// let strategy = PositioningStrategy.cursorPosition()
    /// contextMenu.open(strategy, placement: .bottomStart)
    /// ```
    public static func cursorPosition() -> PositioningStrategy {
        return PositioningStrategy(type: .cursorPosition)
    }
    
    /// Create a strategy for positioning relative to a rectangle.
    ///
    /// - Parameters:
    ///   - rect: Rectangle in screen coordinates to position relative to
    ///   - offset: Optional offset point to apply to the position (default: Point(x: 0, y: 0))
    /// - Returns: PositioningStrategy configured for rectangle-relative positioning
    ///
    /// Example:
    /// ```swift
    /// let buttonRect = button.bounds
    /// // Position at bottom of button (no offset)
    /// let strategy = PositioningStrategy.relative(rect: buttonRect, offset: Point(x: 0, y: 0))
    /// menu.open(strategy)
    ///
    /// // Position at bottom of button with 10px vertical offset
    /// let strategy2 = PositioningStrategy.relative(rect: buttonRect, offset: Point(x: 0, y: 10))
    /// menu.open(strategy2)
    /// ```
    public static func relative(rect: Rect, offset: Point = Point(x: 0, y: 0)) -> PositioningStrategy {
        return PositioningStrategy(type: .relative, relativeRect: rect, relativeOffset: offset)
    }
    
    /// Create a strategy for positioning relative to a window.
    ///
    /// - Parameters:
    ///   - window: Window to position relative to
    ///   - offset: Optional offset point to apply to the position (default: Point(x: 0, y: 0))
    /// - Returns: PositioningStrategy configured for window-relative positioning
    ///
    /// This method stores a reference to the window and will obtain its bounds
    /// dynamically when needed, ensuring the position reflects the window's current state.
    ///
    /// Example:
    /// ```swift
    /// let window = WindowManager.shared.create(options)
    /// // Position menu at bottom of window (no offset)
    /// let strategy = PositioningStrategy.relative(window: window, offset: Point(x: 0, y: 0))
    /// menu.open(strategy)
    ///
    /// // Position menu at bottom of window with 10px vertical offset
    /// let strategy2 = PositioningStrategy.relative(window: window, offset: Point(x: 0, y: 10))
    /// menu.open(strategy2)
    /// ```
    public static func relative(window: Window, offset: Point = Point(x: 0, y: 0)) -> PositioningStrategy {
        return PositioningStrategy(type: .relative, relativeOffset: offset, relativeWindow: window)
    }
    
    internal var nativeValue: native_positioning_strategy_t {
        switch type {
        case .absolute:
            guard let absolutePosition = absolutePosition else {
                fatalError("Absolute positioning strategy requires a point")
            }
            var point = absolutePosition.cStruct
            return native_positioning_strategy_absolute(&point)
            
        case .cursorPosition:
            return native_positioning_strategy_cursor_position()
            
        case .relative:
            if let window = relativeWindow {
                var offset = (relativeOffset ?? Point(x: 0, y: 0)).cStruct
                return native_positioning_strategy_relative_to_window(window.handle, &offset)
            } else if let rect = relativeRect {
                var cRect = rect.cStruct
                var offset = (relativeOffset ?? Point(x: 0, y: 0)).cStruct
                return native_positioning_strategy_relative(&cRect, &offset)
            } else {
                fatalError("Relative positioning strategy requires either a rectangle or a window")
            }
        }
    }
}

