// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

/// One `ApplicationEvent`, in its concrete form.
public enum ApplicationEvent {
  case started
  case exiting(exitCode: CInt)
  case activated
  case deactivated
  case quitRequested

  init?(raw: native_application_event_t) {
    switch raw.type {
    case NATIVE_APPLICATION_EVENT_TYPE_STARTED: self = .started
    case NATIVE_APPLICATION_EVENT_TYPE_EXITING: self = .exiting(exitCode: raw.data.exiting.exit_code)
    case NATIVE_APPLICATION_EVENT_TYPE_ACTIVATED: self = .activated
    case NATIVE_APPLICATION_EVENT_TYPE_DEACTIVATED: self = .deactivated
    case NATIVE_APPLICATION_EVENT_TYPE_QUIT_REQUESTED: self = .quitRequested
    default: return nil
    }
  }
}

public final class Application: Sendable {
  /// The shared instance backed by the native singleton.
  public static let shared = Application()

  private init() {}

  public func run() -> CInt {
    return native_application_run()
  }

  public func runWithWindow(window: Window?) -> CInt {
    return native_application_run_with_window(window?.nativeHandle ?? 0)
  }

  public func quit(exitCode: CInt) -> Void {
    native_application_quit(exitCode)
  }

  public func isRunning() -> Bool {
    return native_application_is_running()
  }

  public func isSingleInstance() -> Bool {
    return native_application_is_single_instance()
  }

  public func setIcon(iconPath: String) -> Bool {
    let iconPathCString = strdup(iconPath)
    defer { free(iconPathCString) }
    return native_application_set_icon(iconPathCString)
  }

  public func setDockIconVisible(visible: Bool) -> Bool {
    return native_application_set_dock_icon_visible(visible)
  }

  public func setMenuBar(menu: Menu?) -> Bool {
    return native_application_set_menu_bar(menu?.nativeHandle ?? 0)
  }

  public func getPrimaryWindow() -> Window? {
    let handle = native_application_get_primary_window()
    guard handle != NATIVE_INVALID_WINDOW else { return nil }
    return Window(nativeHandle: handle)
  }

  public func setPrimaryWindow(window: Window?) -> Void {
    native_application_set_primary_window(window?.nativeHandle ?? 0)
  }

  public func getAllWindows() -> [Window] {
    var list = native_application_get_all_windows()
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

  /// Registers `callback` for every `ApplicationEvent` this `Application` emits.
  ///
  /// The closure is retained for good: the C ABI keeps the context
  /// pointer but offers no hook to release it, so removing the listener
  /// stops the calls without freeing the closure.
  public func addListener(_ callback: @escaping (ApplicationEvent) -> Void) -> ListenerId {
    let context = Unmanaged.passRetained(CallbackBox1<ApplicationEvent>(callback)).toOpaque()
    let trampoline: @convention(c) (UnsafePointer<native_application_event_t>?, UnsafeMutableRawPointer?) -> Void = { event, userData in
      guard let event, let userData, let value = ApplicationEvent(raw: event.pointee) else { return }
      Unmanaged<CallbackBox1<ApplicationEvent>>.fromOpaque(userData).takeUnretainedValue().body(value)
    }
    return native_application_add_listener(trampoline, context)
  }

  /// Unregisters a listener. Returns false if unknown.
  public func removeListener(_ listenerId: ListenerId) -> Bool {
    native_application_remove_listener(listenerId)
  }

}

