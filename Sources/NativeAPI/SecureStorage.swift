// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

/// Owned handle to a native `SecureStorage`.
public final class SecureStorage {
  public let nativeHandle: native_secure_storage_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_secure_storage_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_secure_storage_free(nativeHandle)
    }
  }

  /// Creates a new `SecureStorage`; returns nil if the native side failed.
  public static func create() -> SecureStorage? {
    let handle = native_secure_storage_create()
    guard handle != NATIVE_INVALID_SECURE_STORAGE else { return nil }
    return SecureStorage(nativeHandle: handle)
  }

  /// Creates a new `SecureStorage`; returns nil if the native side failed.
  public static func createWithScope(scope: String) -> SecureStorage? {
    let scopeCString = strdup(scope)
    defer { free(scopeCString) }
    let handle = native_secure_storage_create_with_scope(scopeCString)
    guard handle != NATIVE_INVALID_SECURE_STORAGE else { return nil }
    return SecureStorage(nativeHandle: handle)
  }

  public func set(key: String, value: String) -> Bool {
    let keyCString = strdup(key)
    defer { free(keyCString) }
    let valueCString = strdup(value)
    defer { free(valueCString) }
    return native_secure_storage_set(nativeHandle, keyCString, valueCString)
  }

  public func get(key: String, defaultValue: String) -> String? {
    let keyCString = strdup(key)
    defer { free(keyCString) }
    let defaultValueCString = strdup(defaultValue)
    defer { free(defaultValueCString) }
    guard let value = native_secure_storage_get(nativeHandle, keyCString, defaultValueCString) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func remove(key: String) -> Bool {
    let keyCString = strdup(key)
    defer { free(keyCString) }
    return native_secure_storage_remove(nativeHandle, keyCString)
  }

  public func clear() -> Bool {
    return native_secure_storage_clear(nativeHandle)
  }

  public func contains(key: String) -> Bool {
    let keyCString = strdup(key)
    defer { free(keyCString) }
    return native_secure_storage_contains(nativeHandle, keyCString)
  }

  public var keys: [String] {
    var list = native_secure_storage_get_keys(nativeHandle)
    var items: [String] = []
    if let buffer = list.items {
      for index in 0..<Int(list.count) {
        guard let value = buffer[index] else { continue }
        items.append(String(cString: value))
      }
    }
    native_string_list_free(&list)
    return items
  }

  public var size: CUnsignedLong {
    return native_secure_storage_get_size(nativeHandle)
  }

  public var all: [String: String] {
    var raw = native_secure_storage_get_all(nativeHandle)
    var entries: [String: String] = [:]
    if let keys = raw.keys, let values = raw.values {
      for index in 0..<Int(raw.count) {
        guard let key = keys[index] else { continue }
        let value = values[index].map { String(cString: $0) } ?? ""
        entries[String(cString: key)] = value
      }
    }
    native_string_map_free(&raw)
    return entries
  }

  public var scope: String? {
    guard let value = native_secure_storage_get_scope(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public static func isAvailable() -> Bool {
    return native_secure_storage_is_available()
  }

}

