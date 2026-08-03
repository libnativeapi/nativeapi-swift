// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public enum WindowManager {
  public static func get(id: WindowId) -> Window? {
    let handle = native_window_manager_get(id)
    guard handle != NATIVE_INVALID_WINDOW else { return nil }
    return Window(nativeHandle: handle)
  }

  public static func getAll() -> [Window] {
    var list = native_window_manager_get_all()
    var items: [Window] = []
    if let buffer = list.windows {
      for index in 0..<Int(list.count) {
        items.append(Window(nativeHandle: buffer[index]))
      }
    }
    // The handles now belong to `items`; free just the array.
    native_window_list_release(&list)
    return items
  }

  public static func getCurrent() -> Window? {
    let handle = native_window_manager_get_current()
    guard handle != NATIVE_INVALID_WINDOW else { return nil }
    return Window(nativeHandle: handle)
  }

  public static func setWillShowHook(hook: ((UInt32) -> Void)?) -> Void {
    let hookContext = hook.map { Unmanaged.passRetained(CallbackBox1<UInt32>($0)).toOpaque() }
    let hookTrampoline = { (arg0: UInt32, userData: UnsafeMutableRawPointer?) -> Void in
      guard let userData else { return }
      Unmanaged<CallbackBox1<UInt32>>.fromOpaque(userData).takeUnretainedValue().body(arg0)
    } as @convention(c) (UInt32, UnsafeMutableRawPointer?) -> Void
    native_window_manager_set_will_show_hook(hookContext != nil ? hookTrampoline : nil, hookContext)
  }

  public static func setWillHideHook(hook: ((UInt32) -> Void)?) -> Void {
    let hookContext = hook.map { Unmanaged.passRetained(CallbackBox1<UInt32>($0)).toOpaque() }
    let hookTrampoline = { (arg0: UInt32, userData: UnsafeMutableRawPointer?) -> Void in
      guard let userData else { return }
      Unmanaged<CallbackBox1<UInt32>>.fromOpaque(userData).takeUnretainedValue().body(arg0)
    } as @convention(c) (UInt32, UnsafeMutableRawPointer?) -> Void
    native_window_manager_set_will_hide_hook(hookContext != nil ? hookTrampoline : nil, hookContext)
  }

  public static func hasWillShowHook() -> Bool {
    return native_window_manager_has_will_show_hook()
  }

  public static func hasWillHideHook() -> Bool {
    return native_window_manager_has_will_hide_hook()
  }

  public static func handleWillShow(id: WindowId) -> Void {
    native_window_manager_handle_will_show(id)
  }

  public static func handleWillHide(id: WindowId) -> Void {
    native_window_manager_handle_will_hide(id)
  }

  public static func callOriginalShow(id: WindowId) -> Bool {
    return native_window_manager_call_original_show(id)
  }

  public static func callOriginalHide(id: WindowId) -> Bool {
    return native_window_manager_call_original_hide(id)
  }

  /// Registers `callback` for every `WindowEvent` this `WindowManager` emits.
  ///
  /// The closure is retained for good: the C ABI keeps the context
  /// pointer but offers no hook to release it, so removing the listener
  /// stops the calls without freeing the closure.
  public static func addListener(_ callback: @escaping (WindowEvent) -> Void) -> ListenerId {
    let context = Unmanaged.passRetained(CallbackBox1<WindowEvent>(callback)).toOpaque()
    let trampoline: @convention(c) (UnsafePointer<native_window_event_t>?, UnsafeMutableRawPointer?) -> Void = { event, userData in
      guard let event, let userData, let value = WindowEvent(raw: event.pointee) else { return }
      Unmanaged<CallbackBox1<WindowEvent>>.fromOpaque(userData).takeUnretainedValue().body(value)
    }
    return native_window_manager_add_listener(trampoline, context)
  }

  /// Unregisters a listener. Returns false if unknown.
  public static func removeListener(_ listenerId: ListenerId) -> Bool {
    native_window_manager_remove_listener(listenerId)
  }

}

