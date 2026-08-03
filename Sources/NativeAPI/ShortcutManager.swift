// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public enum ShortcutManager {
  public static func isSupported() -> Bool {
    return native_shortcut_manager_is_supported()
  }

  public static func registerWithAcceleratorAndCallback(accelerator: String, callback: @escaping () -> Void) -> Shortcut? {
    let acceleratorCString = strdup(accelerator)
    defer { free(acceleratorCString) }
    let callbackContext = Unmanaged.passRetained(CallbackBox0(callback)).toOpaque()
    let callbackTrampoline = { (userData: UnsafeMutableRawPointer?) -> Void in
      guard let userData else { return }
      Unmanaged<CallbackBox0>.fromOpaque(userData).takeUnretainedValue().body()
    } as @convention(c) (UnsafeMutableRawPointer?) -> Void
    let handle = native_shortcut_manager_register_with_accelerator_and_callback(acceleratorCString, callbackTrampoline, callbackContext)
    guard handle != NATIVE_INVALID_SHORTCUT else { return nil }
    return Shortcut(nativeHandle: handle)
  }

  public static func registerWithOptions(options: ShortcutOptions) -> Shortcut? {
    var optionsRaw = options.toRaw()
    defer { ShortcutOptions.releaseRaw(&optionsRaw) }
    let handle = native_shortcut_manager_register_with_options(optionsRaw)
    guard handle != NATIVE_INVALID_SHORTCUT else { return nil }
    return Shortcut(nativeHandle: handle)
  }

  public static func unregisterWithId(id: ShortcutId) -> Bool {
    return native_shortcut_manager_unregister_with_id(id)
  }

  public static func unregisterWithAccelerator(accelerator: String) -> Bool {
    let acceleratorCString = strdup(accelerator)
    defer { free(acceleratorCString) }
    return native_shortcut_manager_unregister_with_accelerator(acceleratorCString)
  }

  public static func unregisterAll() -> CInt {
    return native_shortcut_manager_unregister_all()
  }

  public static func getWithId(id: ShortcutId) -> Shortcut? {
    let handle = native_shortcut_manager_get_with_id(id)
    guard handle != NATIVE_INVALID_SHORTCUT else { return nil }
    return Shortcut(nativeHandle: handle)
  }

  public static func getWithAccelerator(accelerator: String) -> Shortcut? {
    let acceleratorCString = strdup(accelerator)
    defer { free(acceleratorCString) }
    let handle = native_shortcut_manager_get_with_accelerator(acceleratorCString)
    guard handle != NATIVE_INVALID_SHORTCUT else { return nil }
    return Shortcut(nativeHandle: handle)
  }

  public static func getAll() -> [Shortcut] {
    var list = native_shortcut_manager_get_all()
    var items: [Shortcut] = []
    if let buffer = list.shortcuts {
      for index in 0..<Int(list.count) {
        items.append(Shortcut(nativeHandle: buffer[index]))
      }
    }
    // The handles now belong to `items`; free just the array.
    native_shortcut_list_release(&list)
    return items
  }

  public static func getByScope(scope: ShortcutScope) -> [Shortcut] {
    var list = native_shortcut_manager_get_by_scope(scope.raw)
    var items: [Shortcut] = []
    if let buffer = list.shortcuts {
      for index in 0..<Int(list.count) {
        items.append(Shortcut(nativeHandle: buffer[index]))
      }
    }
    // The handles now belong to `items`; free just the array.
    native_shortcut_list_release(&list)
    return items
  }

  public static func isAvailable(accelerator: String) -> Bool {
    let acceleratorCString = strdup(accelerator)
    defer { free(acceleratorCString) }
    return native_shortcut_manager_is_available(acceleratorCString)
  }

  public static func isValidAccelerator(accelerator: String) -> Bool {
    let acceleratorCString = strdup(accelerator)
    defer { free(acceleratorCString) }
    return native_shortcut_manager_is_valid_accelerator(acceleratorCString)
  }

  public static func setEnabled(enabled: Bool) -> Void {
    native_shortcut_manager_set_enabled(enabled)
  }

  public static func isEnabled() -> Bool {
    return native_shortcut_manager_is_enabled()
  }

  public static func emitShortcutActivated(id: ShortcutId, accelerator: String) -> Void {
    let acceleratorCString = strdup(accelerator)
    defer { free(acceleratorCString) }
    native_shortcut_manager_emit_shortcut_activated(id, acceleratorCString)
  }

  /// Registers `callback` for every `ShortcutEvent` this `ShortcutManager` emits.
  ///
  /// The closure is retained for good: the C ABI keeps the context
  /// pointer but offers no hook to release it, so removing the listener
  /// stops the calls without freeing the closure.
  public static func addListener(_ callback: @escaping (ShortcutEvent) -> Void) -> ListenerId {
    let context = Unmanaged.passRetained(CallbackBox1<ShortcutEvent>(callback)).toOpaque()
    let trampoline: @convention(c) (UnsafePointer<native_shortcut_event_t>?, UnsafeMutableRawPointer?) -> Void = { event, userData in
      guard let event, let userData, let value = ShortcutEvent(raw: event.pointee) else { return }
      Unmanaged<CallbackBox1<ShortcutEvent>>.fromOpaque(userData).takeUnretainedValue().body(value)
    }
    return native_shortcut_manager_add_listener(trampoline, context)
  }

  /// Unregisters a listener. Returns false if unknown.
  public static func removeListener(_ listenerId: ListenerId) -> Bool {
    native_shortcut_manager_remove_listener(listenerId)
  }

}

