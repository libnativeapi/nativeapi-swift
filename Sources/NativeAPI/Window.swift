// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public typealias WindowId = UInt32

public enum TitleBarStyle: CInt {
  case normal = 0
  case hidden = 1

  init(raw: native_title_bar_style_t) {
    switch raw {
    case NATIVE_TITLE_BAR_STYLE_NORMAL: self = .normal
    case NATIVE_TITLE_BAR_STYLE_HIDDEN: self = .hidden
    default: self = .normal
    }
  }

  var raw: native_title_bar_style_t {
    native_title_bar_style_t(rawValue: UInt32(self.rawValue))
  }
}

public enum VisualEffect: CInt {
  case none = 0
  case blur = 1
  case acrylic = 2
  case mica = 3

  init(raw: native_visual_effect_t) {
    switch raw {
    case NATIVE_VISUAL_EFFECT_NONE: self = .none
    case NATIVE_VISUAL_EFFECT_BLUR: self = .blur
    case NATIVE_VISUAL_EFFECT_ACRYLIC: self = .acrylic
    case NATIVE_VISUAL_EFFECT_MICA: self = .mica
    default: self = .none
    }
  }

  var raw: native_visual_effect_t {
    native_visual_effect_t(rawValue: UInt32(self.rawValue))
  }
}

/// One `WindowEvent`, in its concrete form.
public enum WindowEvent {
  case focused(windowId: WindowId)
  case blurred(windowId: WindowId)
  case minimized(windowId: WindowId)
  case maximized(windowId: WindowId)
  case restored(windowId: WindowId)
  case moved(windowId: WindowId, newPosition: Point)
  case resized(windowId: WindowId, newSize: Size)

  init?(raw: native_window_event_t) {
    switch raw.type {
    case NATIVE_WINDOW_EVENT_TYPE_FOCUSED: self = .focused(windowId: raw.window_id)
    case NATIVE_WINDOW_EVENT_TYPE_BLURRED: self = .blurred(windowId: raw.window_id)
    case NATIVE_WINDOW_EVENT_TYPE_MINIMIZED: self = .minimized(windowId: raw.window_id)
    case NATIVE_WINDOW_EVENT_TYPE_MAXIMIZED: self = .maximized(windowId: raw.window_id)
    case NATIVE_WINDOW_EVENT_TYPE_RESTORED: self = .restored(windowId: raw.window_id)
    case NATIVE_WINDOW_EVENT_TYPE_MOVED: self = .moved(windowId: raw.window_id, newPosition: Point(raw: raw.data.moved.new_position))
    case NATIVE_WINDOW_EVENT_TYPE_RESIZED: self = .resized(windowId: raw.window_id, newSize: Size(raw: raw.data.resized.new_size))
    default: return nil
    }
  }
}

/// Owned handle to a native `Window`.
public final class Window {
  public let nativeHandle: native_window_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_window_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_window_free(nativeHandle)
    }
  }

  /// Creates a new `Window`; returns nil if the native side failed.
  public static func create() -> Window? {
    let handle = native_window_create()
    guard handle != NATIVE_INVALID_WINDOW else { return nil }
    return Window(nativeHandle: handle)
  }

  /// Creates a new `Window`; returns nil if the native side failed.
  public static func createWithNativeWindow(nativeWindow: UnsafeMutableRawPointer?) -> Window? {
    let handle = native_window_create_with_native_window(nativeWindow)
    guard handle != NATIVE_INVALID_WINDOW else { return nil }
    return Window(nativeHandle: handle)
  }

  public var id: WindowId {
    return native_window_get_id(nativeHandle)
  }

  public func focus() -> Void {
    native_window_focus(nativeHandle)
  }

  public func blur() -> Void {
    native_window_blur(nativeHandle)
  }

  public var isFocused: Bool {
    return native_window_is_focused(nativeHandle)
  }

  public func show() -> Void {
    native_window_show(nativeHandle)
  }

  public func showInactive() -> Void {
    native_window_show_inactive(nativeHandle)
  }

  public func hide() -> Void {
    native_window_hide(nativeHandle)
  }

  public var isVisible: Bool {
    return native_window_is_visible(nativeHandle)
  }

  public func maximize() -> Void {
    native_window_maximize(nativeHandle)
  }

  public func unmaximize() -> Void {
    native_window_unmaximize(nativeHandle)
  }

  public var isMaximized: Bool {
    return native_window_is_maximized(nativeHandle)
  }

  public func minimize() -> Void {
    native_window_minimize(nativeHandle)
  }

  public func restore() -> Void {
    native_window_restore(nativeHandle)
  }

  public var isMinimized: Bool {
    return native_window_is_minimized(nativeHandle)
  }

  public func setFullScreen(isFullScreen: Bool) -> Void {
    native_window_set_full_screen(nativeHandle, isFullScreen)
  }

  public var isFullScreen: Bool {
    return native_window_is_full_screen(nativeHandle)
  }

  public func setBounds(bounds: Rectangle) -> Void {
    var boundsRaw = bounds.toRaw()
    native_window_set_bounds(nativeHandle, boundsRaw)
  }

  public var bounds: Rectangle {
    return Rectangle(raw: native_window_get_bounds(nativeHandle))
  }

  public func setContentBounds(bounds: Rectangle) -> Void {
    var boundsRaw = bounds.toRaw()
    native_window_set_content_bounds(nativeHandle, boundsRaw)
  }

  public var contentBounds: Rectangle {
    return Rectangle(raw: native_window_get_content_bounds(nativeHandle))
  }

  public func setSize(size: Size, animate: Bool) -> Void {
    var sizeRaw = size.toRaw()
    native_window_set_size(nativeHandle, sizeRaw, animate)
  }

  public var size: Size {
    return Size(raw: native_window_get_size(nativeHandle))
  }

  public func setContentSize(size: Size) -> Void {
    var sizeRaw = size.toRaw()
    native_window_set_content_size(nativeHandle, sizeRaw)
  }

  public var contentSize: Size {
    return Size(raw: native_window_get_content_size(nativeHandle))
  }

  public func setMinimumSize(size: Size) -> Void {
    var sizeRaw = size.toRaw()
    native_window_set_minimum_size(nativeHandle, sizeRaw)
  }

  public var minimumSize: Size {
    return Size(raw: native_window_get_minimum_size(nativeHandle))
  }

  public func setMaximumSize(size: Size) -> Void {
    var sizeRaw = size.toRaw()
    native_window_set_maximum_size(nativeHandle, sizeRaw)
  }

  public var maximumSize: Size {
    return Size(raw: native_window_get_maximum_size(nativeHandle))
  }

  public func setResizable(isResizable: Bool) -> Void {
    native_window_set_resizable(nativeHandle, isResizable)
  }

  public var isResizable: Bool {
    return native_window_is_resizable(nativeHandle)
  }

  public func setMovable(isMovable: Bool) -> Void {
    native_window_set_movable(nativeHandle, isMovable)
  }

  public var isMovable: Bool {
    return native_window_is_movable(nativeHandle)
  }

  public func setMinimizable(isMinimizable: Bool) -> Void {
    native_window_set_minimizable(nativeHandle, isMinimizable)
  }

  public var isMinimizable: Bool {
    return native_window_is_minimizable(nativeHandle)
  }

  public func setMaximizable(isMaximizable: Bool) -> Void {
    native_window_set_maximizable(nativeHandle, isMaximizable)
  }

  public var isMaximizable: Bool {
    return native_window_is_maximizable(nativeHandle)
  }

  public func setFullScreenable(isFullScreenable: Bool) -> Void {
    native_window_set_full_screenable(nativeHandle, isFullScreenable)
  }

  public var isFullScreenable: Bool {
    return native_window_is_full_screenable(nativeHandle)
  }

  public func setClosable(isClosable: Bool) -> Void {
    native_window_set_closable(nativeHandle, isClosable)
  }

  public var isClosable: Bool {
    return native_window_is_closable(nativeHandle)
  }

  public func setWindowControlButtonsVisible(isVisible: Bool) -> Void {
    native_window_set_window_control_buttons_visible(nativeHandle, isVisible)
  }

  public var isWindowControlButtonsVisible: Bool {
    return native_window_is_window_control_buttons_visible(nativeHandle)
  }

  public func setAlwaysOnTop(isAlwaysOnTop: Bool) -> Void {
    native_window_set_always_on_top(nativeHandle, isAlwaysOnTop)
  }

  public var isAlwaysOnTop: Bool {
    return native_window_is_always_on_top(nativeHandle)
  }

  public func setPosition(point: Point) -> Void {
    var pointRaw = point.toRaw()
    native_window_set_position(nativeHandle, pointRaw)
  }

  public var position: Point {
    return Point(raw: native_window_get_position(nativeHandle))
  }

  public func center() -> Void {
    native_window_center(nativeHandle)
  }

  public func setTitle(title: String) -> Void {
    let titleCString = strdup(title)
    defer { free(titleCString) }
    native_window_set_title(nativeHandle, titleCString)
  }

  public var title: String? {
    guard let value = native_window_get_title(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func setTitleBarStyle(style: TitleBarStyle) -> Void {
    native_window_set_title_bar_style(nativeHandle, style.raw)
  }

  public var titleBarStyle: TitleBarStyle {
    return TitleBarStyle(raw: native_window_get_title_bar_style(nativeHandle))
  }

  public func setHasShadow(hasShadow: Bool) -> Void {
    native_window_set_has_shadow(nativeHandle, hasShadow)
  }

  public var hasShadow: Bool {
    return native_window_has_shadow(nativeHandle)
  }

  public func setOpacity(opacity: Float) -> Void {
    native_window_set_opacity(nativeHandle, opacity)
  }

  public var opacity: Float {
    return native_window_get_opacity(nativeHandle)
  }

  public func setVisualEffect(effect: VisualEffect) -> Void {
    native_window_set_visual_effect(nativeHandle, effect.raw)
  }

  public var visualEffect: VisualEffect {
    return VisualEffect(raw: native_window_get_visual_effect(nativeHandle))
  }

  public func setBackgroundColor(color: Color) -> Void {
    var colorRaw = color.toRaw()
    native_window_set_background_color(nativeHandle, colorRaw)
  }

  public var backgroundColor: Color {
    return Color(raw: native_window_get_background_color(nativeHandle))
  }

  public func setVisibleOnAllWorkspaces(isVisibleOnAllWorkspaces: Bool) -> Void {
    native_window_set_visible_on_all_workspaces(nativeHandle, isVisibleOnAllWorkspaces)
  }

  public var isVisibleOnAllWorkspaces: Bool {
    return native_window_is_visible_on_all_workspaces(nativeHandle)
  }

  public func setIgnoreMouseEvents(isIgnoreMouseEvents: Bool) -> Void {
    native_window_set_ignore_mouse_events(nativeHandle, isIgnoreMouseEvents)
  }

  public var isIgnoreMouseEvents: Bool {
    return native_window_is_ignore_mouse_events(nativeHandle)
  }

  public func setFocusable(isFocusable: Bool) -> Void {
    native_window_set_focusable(nativeHandle, isFocusable)
  }

  public var isFocusable: Bool {
    return native_window_is_focusable(nativeHandle)
  }

  public func startDragging() -> Void {
    native_window_start_dragging(nativeHandle)
  }

  public func startResizing() -> Void {
    native_window_start_resizing(nativeHandle)
  }

  /// Platform-specific native object behind this handle.
  public var nativeObject: UnsafeMutableRawPointer? {
    native_window_get_native_object(nativeHandle)
  }

}

