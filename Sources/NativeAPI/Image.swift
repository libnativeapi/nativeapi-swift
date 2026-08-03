// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

/// Owned handle to a native `Image`.
public final class Image {
  public let nativeHandle: native_image_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_image_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_image_free(nativeHandle)
    }
  }

  public static func fromFile(filePath: String) -> Image? {
    let filePathCString = strdup(filePath)
    defer { free(filePathCString) }
    let handle = native_image_from_file(filePathCString)
    guard handle != NATIVE_INVALID_IMAGE else { return nil }
    return Image(nativeHandle: handle)
  }

  public static func fromBase64(base64Data: String) -> Image? {
    let base64DataCString = strdup(base64Data)
    defer { free(base64DataCString) }
    let handle = native_image_from_base64(base64DataCString)
    guard handle != NATIVE_INVALID_IMAGE else { return nil }
    return Image(nativeHandle: handle)
  }

  public var size: Size {
    return Size(raw: native_image_get_size(nativeHandle))
  }

  public var format: String? {
    guard let value = native_image_get_format(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func toBase64() -> String? {
    guard let value = native_image_to_base64(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func saveToFile(filePath: String) -> Bool {
    let filePathCString = strdup(filePath)
    defer { free(filePathCString) }
    return native_image_save_to_file(nativeHandle, filePathCString)
  }

  /// Platform-specific native object behind this handle.
  public var nativeObject: UnsafeMutableRawPointer? {
    native_image_get_native_object(nativeHandle)
  }

}

