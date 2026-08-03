// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public typealias TrayIconId = UInt32

public enum ContextMenuTrigger: CInt {
  case none = 0
  case clicked = 1
  case rightClicked = 2
  case doubleClicked = 3

  init(raw: native_context_menu_trigger_t) {
    switch raw {
    case NATIVE_CONTEXT_MENU_TRIGGER_NONE: self = .none
    case NATIVE_CONTEXT_MENU_TRIGGER_CLICKED: self = .clicked
    case NATIVE_CONTEXT_MENU_TRIGGER_RIGHT_CLICKED: self = .rightClicked
    case NATIVE_CONTEXT_MENU_TRIGGER_DOUBLE_CLICKED: self = .doubleClicked
    default: self = .none
    }
  }

  var raw: native_context_menu_trigger_t {
    native_context_menu_trigger_t(rawValue: UInt32(self.rawValue))
  }
}

/// One `TrayIconEvent`, in its concrete form.
public enum TrayIconEvent {
  case clicked(trayIconId: TrayIconId)
  case rightClicked(trayIconId: TrayIconId)
  case doubleClicked(trayIconId: TrayIconId)

  init?(raw: native_tray_icon_event_t) {
    switch raw.type {
    case NATIVE_TRAY_ICON_EVENT_TYPE_CLICKED: self = .clicked(trayIconId: raw.data.clicked.tray_icon_id)
    case NATIVE_TRAY_ICON_EVENT_TYPE_RIGHT_CLICKED: self = .rightClicked(trayIconId: raw.data.right_clicked.tray_icon_id)
    case NATIVE_TRAY_ICON_EVENT_TYPE_DOUBLE_CLICKED: self = .doubleClicked(trayIconId: raw.data.double_clicked.tray_icon_id)
    default: return nil
    }
  }
}

/// Owned handle to a native `TrayIcon`.
public final class TrayIcon {
  public let nativeHandle: native_tray_icon_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_tray_icon_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_tray_icon_free(nativeHandle)
    }
  }

  /// Creates a new `TrayIcon`; returns nil if the native side failed.
  public static func create() -> TrayIcon? {
    let handle = native_tray_icon_create()
    guard handle != NATIVE_INVALID_TRAY_ICON else { return nil }
    return TrayIcon(nativeHandle: handle)
  }

  /// Creates a new `TrayIcon`; returns nil if the native side failed.
  public static func createWithTray(tray: UnsafeMutableRawPointer?) -> TrayIcon? {
    let handle = native_tray_icon_create_with_tray(tray)
    guard handle != NATIVE_INVALID_TRAY_ICON else { return nil }
    return TrayIcon(nativeHandle: handle)
  }

  public func getId() -> TrayIconId {
    return native_tray_icon_get_id(nativeHandle)
  }

  public func setIcon(image: Image) -> Void {
    native_tray_icon_set_icon(nativeHandle, image.nativeHandle)
  }

  public var icon: Image? {
    let handle = native_tray_icon_get_icon(nativeHandle)
    guard handle != NATIVE_INVALID_IMAGE else { return nil }
    return Image(nativeHandle: handle)
  }

  public func setTitle(title: String?) -> Void {
    let titleCString = title.map { strdup($0) } ?? nil
    defer { free(titleCString) }
    native_tray_icon_set_title(nativeHandle, titleCString)
  }

  public func getTitle() -> String? {
    guard let value = native_tray_icon_get_title(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func setTooltip(tooltip: String?) -> Void {
    let tooltipCString = tooltip.map { strdup($0) } ?? nil
    defer { free(tooltipCString) }
    native_tray_icon_set_tooltip(nativeHandle, tooltipCString)
  }

  public func getTooltip() -> String? {
    guard let value = native_tray_icon_get_tooltip(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func setContextMenu(menu: Menu) -> Void {
    native_tray_icon_set_context_menu(nativeHandle, menu.nativeHandle)
  }

  public func getContextMenu() -> Menu? {
    let handle = native_tray_icon_get_context_menu(nativeHandle)
    guard handle != NATIVE_INVALID_MENU else { return nil }
    return Menu(nativeHandle: handle)
  }

  public func setContextMenuTrigger(trigger: ContextMenuTrigger) -> Void {
    native_tray_icon_set_context_menu_trigger(nativeHandle, trigger.raw)
  }

  public func getContextMenuTrigger() -> ContextMenuTrigger {
    return ContextMenuTrigger(raw: native_tray_icon_get_context_menu_trigger(nativeHandle))
  }

  public func getBounds() -> Rectangle {
    return Rectangle(raw: native_tray_icon_get_bounds(nativeHandle))
  }

  public func setVisible(visible: Bool) -> Bool {
    return native_tray_icon_set_visible(nativeHandle, visible)
  }

  public func isVisible() -> Bool {
    return native_tray_icon_is_visible(nativeHandle)
  }

  public func openContextMenu() -> Bool {
    return native_tray_icon_open_context_menu(nativeHandle)
  }

  public func closeContextMenu() -> Bool {
    return native_tray_icon_close_context_menu(nativeHandle)
  }

  /// Platform-specific native object behind this handle.
  public var nativeObject: UnsafeMutableRawPointer? {
    native_tray_icon_get_native_object(nativeHandle)
  }

  /// Registers `callback` for every `TrayIconEvent` this `TrayIcon` emits.
  ///
  /// The closure is retained for good: the C ABI keeps the context
  /// pointer but offers no hook to release it, so removing the listener
  /// stops the calls without freeing the closure.
  public func addListener(_ callback: @escaping (TrayIconEvent) -> Void) -> ListenerId {
    let context = Unmanaged.passRetained(CallbackBox1<TrayIconEvent>(callback)).toOpaque()
    let trampoline: @convention(c) (UnsafePointer<native_tray_icon_event_t>?, UnsafeMutableRawPointer?) -> Void = { event, userData in
      guard let event, let userData, let value = TrayIconEvent(raw: event.pointee) else { return }
      Unmanaged<CallbackBox1<TrayIconEvent>>.fromOpaque(userData).takeUnretainedValue().body(value)
    }
    return native_tray_icon_add_listener(nativeHandle, trampoline, context)
  }

  /// Unregisters a listener. Returns false if unknown.
  public func removeListener(_ listenerId: ListenerId) -> Bool {
    native_tray_icon_remove_listener(nativeHandle, listenerId)
  }

}

