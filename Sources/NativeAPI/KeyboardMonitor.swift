// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

/// Owned handle to a native `KeyboardMonitor`.
public final class KeyboardMonitor {
  public let nativeHandle: native_keyboard_monitor_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_keyboard_monitor_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_keyboard_monitor_free(nativeHandle)
    }
  }

  /// Creates a new `KeyboardMonitor`; returns nil if the native side failed.
  public static func create() -> KeyboardMonitor? {
    let handle = native_keyboard_monitor_create()
    guard handle != NATIVE_INVALID_KEYBOARD_MONITOR else { return nil }
    return KeyboardMonitor(nativeHandle: handle)
  }

  public func start() -> Void {
    native_keyboard_monitor_start(nativeHandle)
  }

  public func stop() -> Void {
    native_keyboard_monitor_stop(nativeHandle)
  }

  public var isMonitoring: Bool {
    return native_keyboard_monitor_is_monitoring(nativeHandle)
  }

  /// Registers `callback` for every `KeyboardEvent` this `KeyboardMonitor` emits.
  ///
  /// The closure is retained for good: the C ABI keeps the context
  /// pointer but offers no hook to release it, so removing the listener
  /// stops the calls without freeing the closure.
  public func addListener(_ callback: @escaping (KeyboardEvent) -> Void) -> ListenerId {
    let context = Unmanaged.passRetained(CallbackBox1<KeyboardEvent>(callback)).toOpaque()
    let trampoline: @convention(c) (UnsafePointer<native_keyboard_event_t>?, UnsafeMutableRawPointer?) -> Void = { event, userData in
      guard let event, let userData, let value = KeyboardEvent(raw: event.pointee) else { return }
      Unmanaged<CallbackBox1<KeyboardEvent>>.fromOpaque(userData).takeUnretainedValue().body(value)
    }
    return native_keyboard_monitor_add_listener(nativeHandle, trampoline, context)
  }

  /// Unregisters a listener. Returns false if unknown.
  public func removeListener(_ listenerId: ListenerId) -> Bool {
    native_keyboard_monitor_remove_listener(nativeHandle, listenerId)
  }

}

