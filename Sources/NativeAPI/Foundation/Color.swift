// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public struct Color {
  public var r: UInt8
  public var g: UInt8
  public var b: UInt8
  public var a: UInt8

  public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
    self.r = r
    self.g = g
    self.b = b
    self.a = a
  }
}

extension Color {
  init(raw: native_color_t) {
    self.init(r: raw.r, g: raw.g, b: raw.b, a: raw.a)
  }

  func toRaw() -> native_color_t {
    var raw = native_color_t()
    raw.r = self.r
    raw.g = self.g
    raw.b = self.b
    raw.a = self.a
    return raw
  }
}

