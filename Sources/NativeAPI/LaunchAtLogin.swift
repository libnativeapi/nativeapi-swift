// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

/// Owned handle to a native `LaunchAtLogin`.
public final class LaunchAtLogin {
  public let nativeHandle: native_launch_at_login_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_launch_at_login_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_launch_at_login_free(nativeHandle)
    }
  }

  /// Creates a new `LaunchAtLogin`; returns nil if the native side failed.
  public static func create() -> LaunchAtLogin? {
    let handle = native_launch_at_login_create()
    guard handle != NATIVE_INVALID_LAUNCH_AT_LOGIN else { return nil }
    return LaunchAtLogin(nativeHandle: handle)
  }

  /// Creates a new `LaunchAtLogin`; returns nil if the native side failed.
  public static func createWithId(id: String) -> LaunchAtLogin? {
    let idCString = strdup(id)
    defer { free(idCString) }
    let handle = native_launch_at_login_create_with_id(idCString)
    guard handle != NATIVE_INVALID_LAUNCH_AT_LOGIN else { return nil }
    return LaunchAtLogin(nativeHandle: handle)
  }

  /// Creates a new `LaunchAtLogin`; returns nil if the native side failed.
  public static func createWithIdAndDisplayName(id: String, displayName: String) -> LaunchAtLogin? {
    let idCString = strdup(id)
    defer { free(idCString) }
    let displayNameCString = strdup(displayName)
    defer { free(displayNameCString) }
    let handle = native_launch_at_login_create_with_id_and_display_name(idCString, displayNameCString)
    guard handle != NATIVE_INVALID_LAUNCH_AT_LOGIN else { return nil }
    return LaunchAtLogin(nativeHandle: handle)
  }

  public static func isSupported() -> Bool {
    return native_launch_at_login_is_supported()
  }

  public var id: String? {
    guard let value = native_launch_at_login_get_id(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public var displayName: String? {
    guard let value = native_launch_at_login_get_display_name(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func setDisplayName(displayName: String) -> Bool {
    let displayNameCString = strdup(displayName)
    defer { free(displayNameCString) }
    return native_launch_at_login_set_display_name(nativeHandle, displayNameCString)
  }

  public func setProgram(executablePath: String, arguments: [String]) -> Bool {
    let executablePathCString = strdup(executablePath)
    defer { free(executablePathCString) }
    var argumentsPointers = arguments.map { strdup($0) }
    defer { argumentsPointers.forEach { free($0) } }
    var argumentsList = native_string_list_t(items: &argumentsPointers, count: Int(bitPattern: UInt(argumentsPointers.count)))
    return native_launch_at_login_set_program(nativeHandle, executablePathCString, argumentsList)
  }

  public var executablePath: String? {
    guard let value = native_launch_at_login_get_executable_path(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public var arguments: [String] {
    var list = native_launch_at_login_get_arguments(nativeHandle)
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

  public func enable() -> Bool {
    return native_launch_at_login_enable(nativeHandle)
  }

  public func disable() -> Bool {
    return native_launch_at_login_disable(nativeHandle)
  }

  public var isEnabled: Bool {
    return native_launch_at_login_is_enabled(nativeHandle)
  }

}

