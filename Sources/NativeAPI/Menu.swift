// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public typealias MenuId = UInt32

public typealias MenuItemId = UInt32

public enum MenuItemType: CInt {
  case normal = 0
  case checkbox = 1
  case radio = 2
  case separator = 3
  case submenu = 4

  init(raw: native_menu_item_type_t) {
    switch raw {
    case NATIVE_MENU_ITEM_TYPE_NORMAL: self = .normal
    case NATIVE_MENU_ITEM_TYPE_CHECKBOX: self = .checkbox
    case NATIVE_MENU_ITEM_TYPE_RADIO: self = .radio
    case NATIVE_MENU_ITEM_TYPE_SEPARATOR: self = .separator
    case NATIVE_MENU_ITEM_TYPE_SUBMENU: self = .submenu
    default: self = .normal
    }
  }

  var raw: native_menu_item_type_t {
    native_menu_item_type_t(rawValue: UInt32(self.rawValue))
  }
}

public enum MenuItemState: CInt {
  case unchecked = 0
  case checked = 1
  case mixed = 2

  init(raw: native_menu_item_state_t) {
    switch raw {
    case NATIVE_MENU_ITEM_STATE_UNCHECKED: self = .unchecked
    case NATIVE_MENU_ITEM_STATE_CHECKED: self = .checked
    case NATIVE_MENU_ITEM_STATE_MIXED: self = .mixed
    default: self = .unchecked
    }
  }

  var raw: native_menu_item_state_t {
    native_menu_item_state_t(rawValue: UInt32(self.rawValue))
  }
}

/// One `MenuEvent`, in its concrete form.
public enum MenuEvent {
  case opened(menuId: MenuId)
  case closed(menuId: MenuId)
  case itemClicked(itemId: MenuItemId)
  case itemSubmenuOpened(itemId: MenuItemId)
  case itemSubmenuClosed(itemId: MenuItemId)

  init?(raw: native_menu_event_t) {
    switch raw.type {
    case NATIVE_MENU_EVENT_TYPE_OPENED: self = .opened(menuId: raw.data.opened.menu_id)
    case NATIVE_MENU_EVENT_TYPE_CLOSED: self = .closed(menuId: raw.data.closed.menu_id)
    case NATIVE_MENU_EVENT_TYPE_ITEM_CLICKED: self = .itemClicked(itemId: raw.data.item_clicked.item_id)
    case NATIVE_MENU_EVENT_TYPE_ITEM_SUBMENU_OPENED: self = .itemSubmenuOpened(itemId: raw.data.item_submenu_opened.item_id)
    case NATIVE_MENU_EVENT_TYPE_ITEM_SUBMENU_CLOSED: self = .itemSubmenuClosed(itemId: raw.data.item_submenu_closed.item_id)
    default: return nil
    }
  }
}

/// Owned handle to a native `MenuItem`.
public final class MenuItem {
  public let nativeHandle: native_menu_item_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_menu_item_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_menu_item_free(nativeHandle)
    }
  }

  /// Creates a new `MenuItem`; returns nil if the native side failed.
  public static func createWithLabelAndType(label: String, type: MenuItemType) -> MenuItem? {
    let labelCString = strdup(label)
    defer { free(labelCString) }
    let handle = native_menu_item_create_with_label_and_type(labelCString, type.raw)
    guard handle != NATIVE_INVALID_MENU_ITEM else { return nil }
    return MenuItem(nativeHandle: handle)
  }

  /// Creates a new `MenuItem`; returns nil if the native side failed.
  public static func createWithNativeItem(nativeItem: UnsafeMutableRawPointer?) -> MenuItem? {
    let handle = native_menu_item_create_with_native_item(nativeItem)
    guard handle != NATIVE_INVALID_MENU_ITEM else { return nil }
    return MenuItem(nativeHandle: handle)
  }

  public var id: MenuItemId {
    return native_menu_item_get_id(nativeHandle)
  }

  public var type: MenuItemType {
    return MenuItemType(raw: native_menu_item_get_type(nativeHandle))
  }

  public func setLabel(label: String?) -> Void {
    let labelCString = label.map { strdup($0) } ?? nil
    defer { free(labelCString) }
    native_menu_item_set_label(nativeHandle, labelCString)
  }

  public var label: String? {
    guard let value = native_menu_item_get_label(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func setIcon(image: Image?) -> Void {
    native_menu_item_set_icon(nativeHandle, image?.nativeHandle ?? 0)
  }

  public var icon: Image? {
    let handle = native_menu_item_get_icon(nativeHandle)
    guard handle != NATIVE_INVALID_IMAGE else { return nil }
    return Image(nativeHandle: handle)
  }

  public func setTooltip(tooltip: String?) -> Void {
    let tooltipCString = tooltip.map { strdup($0) } ?? nil
    defer { free(tooltipCString) }
    native_menu_item_set_tooltip(nativeHandle, tooltipCString)
  }

  public var tooltip: String? {
    guard let value = native_menu_item_get_tooltip(nativeHandle) else { return nil }
    defer { free_c_str(value) }
    return String(cString: value)
  }

  public func setAccelerator(accelerator: KeyboardAccelerator?) -> Void {
    let acceleratorPointer = accelerator.map { value -> UnsafeMutablePointer<native_keyboard_accelerator_t> in
      let pointer = UnsafeMutablePointer<native_keyboard_accelerator_t>.allocate(capacity: 1)
      pointer.initialize(to: value.toRaw())
      return pointer
    }
    defer {
      if let pointer = acceleratorPointer {
        KeyboardAccelerator.releaseRaw(&pointer.pointee)
        pointer.deinitialize(count: 1)
        pointer.deallocate()
      }
    }
    native_menu_item_set_accelerator(nativeHandle, acceleratorPointer)
  }

  public var accelerator: KeyboardAccelerator {
    return KeyboardAccelerator(raw: native_menu_item_get_accelerator(nativeHandle))
  }

  public func setEnabled(enabled: Bool) -> Void {
    native_menu_item_set_enabled(nativeHandle, enabled)
  }

  public var isEnabled: Bool {
    return native_menu_item_is_enabled(nativeHandle)
  }

  public func setState(state: MenuItemState) -> Void {
    native_menu_item_set_state(nativeHandle, state.raw)
  }

  public var state: MenuItemState {
    return MenuItemState(raw: native_menu_item_get_state(nativeHandle))
  }

  public func setRadioGroup(groupId: CInt) -> Void {
    native_menu_item_set_radio_group(nativeHandle, groupId)
  }

  public var radioGroup: CInt {
    return native_menu_item_get_radio_group(nativeHandle)
  }

  public func setSubmenu(submenu: Menu?) -> Void {
    native_menu_item_set_submenu(nativeHandle, submenu?.nativeHandle ?? 0)
  }

  public var submenu: Menu? {
    let handle = native_menu_item_get_submenu(nativeHandle)
    guard handle != NATIVE_INVALID_MENU else { return nil }
    return Menu(nativeHandle: handle)
  }

  /// Platform-specific native object behind this handle.
  public var nativeObject: UnsafeMutableRawPointer? {
    native_menu_item_get_native_object(nativeHandle)
  }

  /// Registers `callback` for every `MenuEvent` this `MenuItem` emits.
  ///
  /// The closure is retained for good: the C ABI keeps the context
  /// pointer but offers no hook to release it, so removing the listener
  /// stops the calls without freeing the closure.
  public func addListener(_ callback: @escaping (MenuEvent) -> Void) -> ListenerId {
    let context = Unmanaged.passRetained(CallbackBox1<MenuEvent>(callback)).toOpaque()
    let trampoline: @convention(c) (UnsafePointer<native_menu_event_t>?, UnsafeMutableRawPointer?) -> Void = { event, userData in
      guard let event, let userData, let value = MenuEvent(raw: event.pointee) else { return }
      Unmanaged<CallbackBox1<MenuEvent>>.fromOpaque(userData).takeUnretainedValue().body(value)
    }
    return native_menu_item_add_listener(nativeHandle, trampoline, context)
  }

  /// Unregisters a listener. Returns false if unknown.
  public func removeListener(_ listenerId: ListenerId) -> Bool {
    native_menu_item_remove_listener(nativeHandle, listenerId)
  }

}

/// Owned handle to a native `Menu`.
public final class Menu {
  public let nativeHandle: native_menu_t
  private let ownsHandle: Bool

  public init(nativeHandle: native_menu_t, ownsHandle: Bool = true) {
    self.nativeHandle = nativeHandle
    self.ownsHandle = ownsHandle
  }

  deinit {
    if ownsHandle {
      native_menu_free(nativeHandle)
    }
  }

  /// Creates a new `Menu`; returns nil if the native side failed.
  public static func create() -> Menu? {
    let handle = native_menu_create()
    guard handle != NATIVE_INVALID_MENU else { return nil }
    return Menu(nativeHandle: handle)
  }

  /// Creates a new `Menu`; returns nil if the native side failed.
  public static func createWithNativeMenu(nativeMenu: UnsafeMutableRawPointer?) -> Menu? {
    let handle = native_menu_create_with_native_menu(nativeMenu)
    guard handle != NATIVE_INVALID_MENU else { return nil }
    return Menu(nativeHandle: handle)
  }

  public var id: MenuId {
    return native_menu_get_id(nativeHandle)
  }

  public func addItem(item: MenuItem?) -> Void {
    native_menu_add_item(nativeHandle, item?.nativeHandle ?? 0)
  }

  public func insertItem(index: CUnsignedLong, item: MenuItem?) -> Void {
    native_menu_insert_item(nativeHandle, index, item?.nativeHandle ?? 0)
  }

  public func removeItem(item: MenuItem?) -> Bool {
    return native_menu_remove_item(nativeHandle, item?.nativeHandle ?? 0)
  }

  public func removeItemById(itemId: MenuItemId) -> Bool {
    return native_menu_remove_item_by_id(nativeHandle, itemId)
  }

  public func removeItemAt(index: CUnsignedLong) -> Bool {
    return native_menu_remove_item_at(nativeHandle, index)
  }

  public func clear() -> Void {
    native_menu_clear(nativeHandle)
  }

  public func addSeparator() -> Void {
    native_menu_add_separator(nativeHandle)
  }

  public func insertSeparator(index: CUnsignedLong) -> Void {
    native_menu_insert_separator(nativeHandle, index)
  }

  public var itemCount: CUnsignedLong {
    return native_menu_get_item_count(nativeHandle)
  }

  public func getItemAt(index: CUnsignedLong) -> MenuItem? {
    let handle = native_menu_get_item_at(nativeHandle, index)
    guard handle != NATIVE_INVALID_MENU_ITEM else { return nil }
    return MenuItem(nativeHandle: handle)
  }

  public func getItemById(itemId: MenuItemId) -> MenuItem? {
    let handle = native_menu_get_item_by_id(nativeHandle, itemId)
    guard handle != NATIVE_INVALID_MENU_ITEM else { return nil }
    return MenuItem(nativeHandle: handle)
  }

  public var allItems: [MenuItem] {
    var list = native_menu_get_all_items(nativeHandle)
    var items: [MenuItem] = []
    if let buffer = list.menu_items {
      for index in 0..<Int(list.count) {
        items.append(MenuItem(nativeHandle: buffer[index]))
      }
    }
    // The handles now belong to `items`; free just the array.
    native_menu_item_list_release(&list)
    return items
  }

  public func open(strategy: PositioningStrategy, placement: Placement) -> Bool {
    return native_menu_open(nativeHandle, strategy.nativeHandle, placement.raw)
  }

  public func close() -> Bool {
    return native_menu_close(nativeHandle)
  }

  /// Platform-specific native object behind this handle.
  public var nativeObject: UnsafeMutableRawPointer? {
    native_menu_get_native_object(nativeHandle)
  }

  /// Registers `callback` for every `MenuEvent` this `Menu` emits.
  ///
  /// The closure is retained for good: the C ABI keeps the context
  /// pointer but offers no hook to release it, so removing the listener
  /// stops the calls without freeing the closure.
  public func addListener(_ callback: @escaping (MenuEvent) -> Void) -> ListenerId {
    let context = Unmanaged.passRetained(CallbackBox1<MenuEvent>(callback)).toOpaque()
    let trampoline: @convention(c) (UnsafePointer<native_menu_event_t>?, UnsafeMutableRawPointer?) -> Void = { event, userData in
      guard let event, let userData, let value = MenuEvent(raw: event.pointee) else { return }
      Unmanaged<CallbackBox1<MenuEvent>>.fromOpaque(userData).takeUnretainedValue().body(value)
    }
    return native_menu_add_listener(nativeHandle, trampoline, context)
  }

  /// Unregisters a listener. Returns false if unknown.
  public func removeListener(_ listenerId: ListenerId) -> Bool {
    native_menu_remove_listener(nativeHandle, listenerId)
  }

}

