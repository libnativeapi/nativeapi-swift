// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

/// Owned handle to a native `MessageDialog`.
public final class MessageDialog {
  public let nativeHandle: native_message_dialog_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_message_dialog_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_message_dialog_free(nativeHandle)
    }
  }

  /// Creates a new `MessageDialog`; returns nil if the native side failed.
  public static func create(title: String, message: String) -> MessageDialog? {
    let titleCString = strdup(title)
    defer { free(titleCString) }
    let messageCString = strdup(message)
    defer { free(messageCString) }
    let handle = native_message_dialog_create(titleCString, messageCString)
    guard handle != NATIVE_INVALID_MESSAGE_DIALOG else { return nil }
    return MessageDialog(nativeHandle: handle)
  }

  public func setTitle(title: String) -> Void {
    let titleCString = strdup(title)
    defer { free(titleCString) }
    native_message_dialog_set_title(nativeHandle, titleCString)
  }

  public var title: String? {
    guard let value = native_message_dialog_get_title(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func setMessage(message: String) -> Void {
    let messageCString = strdup(message)
    defer { free(messageCString) }
    native_message_dialog_set_message(nativeHandle, messageCString)
  }

  public var message: String? {
    guard let value = native_message_dialog_get_message(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public var modality: DialogModality {
    return DialogModality(raw: native_message_dialog_get_modality(nativeHandle))
  }

  public func setModality(modality: DialogModality) -> Void {
    native_message_dialog_set_modality(nativeHandle, modality.raw)
  }

  public func open() -> Bool {
    return native_message_dialog_open(nativeHandle)
  }

  public func close() -> Bool {
    return native_message_dialog_close(nativeHandle)
  }

}

