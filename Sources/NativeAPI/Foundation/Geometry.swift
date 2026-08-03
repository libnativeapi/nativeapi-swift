// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public struct Point {
  public var x: Double
  public var y: Double

  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}

extension Point {
  init(raw: native_point_t) {
    self.init(x: raw.x, y: raw.y)
  }

  func toRaw() -> native_point_t {
    var raw = native_point_t()
    raw.x = self.x
    raw.y = self.y
    return raw
  }
}

public struct Size {
  public var width: Double
  public var height: Double

  public init(width: Double, height: Double) {
    self.width = width
    self.height = height
  }
}

extension Size {
  init(raw: native_size_t) {
    self.init(width: raw.width, height: raw.height)
  }

  func toRaw() -> native_size_t {
    var raw = native_size_t()
    raw.width = self.width
    raw.height = self.height
    return raw
  }
}

public struct Rectangle {
  public var x: Double
  public var y: Double
  public var width: Double
  public var height: Double

  public init(x: Double, y: Double, width: Double, height: Double) {
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  }
}

extension Rectangle {
  init(raw: native_rectangle_t) {
    self.init(x: raw.x, y: raw.y, width: raw.width, height: raw.height)
  }

  func toRaw() -> native_rectangle_t {
    var raw = native_rectangle_t()
    raw.x = self.x
    raw.y = self.y
    raw.width = self.width
    raw.height = self.height
    return raw
  }
}

