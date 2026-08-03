// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public enum PositioningStrategyType: CInt {
  case absolute = 0
  case cursorPosition = 1
  case relative = 2

  init(raw: native_positioning_strategy_type_t) {
    switch raw {
    case NATIVE_POSITIONING_STRATEGY_TYPE_ABSOLUTE: self = .absolute
    case NATIVE_POSITIONING_STRATEGY_TYPE_CURSOR_POSITION: self = .cursorPosition
    case NATIVE_POSITIONING_STRATEGY_TYPE_RELATIVE: self = .relative
    default: self = .absolute
    }
  }

  var raw: native_positioning_strategy_type_t {
    native_positioning_strategy_type_t(rawValue: UInt32(self.rawValue))
  }
}

/// Owned handle to a native `PositioningStrategy`.
public final class PositioningStrategy {
  public let nativeHandle: native_positioning_strategy_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_positioning_strategy_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_positioning_strategy_free(nativeHandle)
    }
  }

  public static func absolute(point: Point) -> PositioningStrategy? {
    var pointRaw = point.toRaw()
    let handle = native_positioning_strategy_absolute(pointRaw)
    guard handle != NATIVE_INVALID_POSITIONING_STRATEGY else { return nil }
    return PositioningStrategy(nativeHandle: handle)
  }

  public static func cursorPosition() -> PositioningStrategy? {
    let handle = native_positioning_strategy_cursor_position()
    guard handle != NATIVE_INVALID_POSITIONING_STRATEGY else { return nil }
    return PositioningStrategy(nativeHandle: handle)
  }

  public static func relativeWithRectAndOffset(rect: Rectangle, offset: Point) -> PositioningStrategy? {
    var rectRaw = rect.toRaw()
    var offsetRaw = offset.toRaw()
    let handle = native_positioning_strategy_relative_with_rect_and_offset(rectRaw, offsetRaw)
    guard handle != NATIVE_INVALID_POSITIONING_STRATEGY else { return nil }
    return PositioningStrategy(nativeHandle: handle)
  }

  public static func relativeWithWindowAndOffset(window: Window, offset: Point) -> PositioningStrategy? {
    var offsetRaw = offset.toRaw()
    let handle = native_positioning_strategy_relative_with_window_and_offset(window.nativeHandle, offsetRaw)
    guard handle != NATIVE_INVALID_POSITIONING_STRATEGY else { return nil }
    return PositioningStrategy(nativeHandle: handle)
  }

  public var type: PositioningStrategyType {
    return PositioningStrategyType(raw: native_positioning_strategy_get_type(nativeHandle))
  }

  public var absolutePosition: Point {
    return Point(raw: native_positioning_strategy_get_absolute_position(nativeHandle))
  }

  public var relativeRectangle: Rectangle {
    return Rectangle(raw: native_positioning_strategy_get_relative_rectangle(nativeHandle))
  }

  public var relativeOffset: Point {
    return Point(raw: native_positioning_strategy_get_relative_offset(nativeHandle))
  }

}

