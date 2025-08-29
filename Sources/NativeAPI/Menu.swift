import CNativeAPI
import Foundation

/// Menu item types
public enum MenuItemType: Int32 {
    case normal = 0
    case checkbox = 1
    case radio = 2
    case separator = 3
    case submenu = 4
}

/// Keyboard accelerator modifier flags
public struct AcceleratorModifier: OptionSet, Sendable {
    public let rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    public static let none = AcceleratorModifier([])
    public static let ctrl = AcceleratorModifier(rawValue: 1 << 0)
    public static let alt = AcceleratorModifier(rawValue: 1 << 1)
    public static let shift = AcceleratorModifier(rawValue: 1 << 2)
    public static let meta = AcceleratorModifier(rawValue: 1 << 3)
}

/// Keyboard accelerator for menu items
public struct KeyboardAccelerator {
    public let modifiers: AcceleratorModifier
    public let key: String

    public init(key: String, modifiers: AcceleratorModifier = .none) {
        self.key = key
        self.modifiers = modifiers
    }

    internal var cStruct: native_keyboard_accelerator_t {
        var accelerator = native_keyboard_accelerator_t()
        accelerator.modifiers = modifiers.rawValue
        key.withCString { cString in
            let length = min(strlen(cString), 63)
            withUnsafeMutableBytes(of: &accelerator.key) { ptr in
                let buffer = ptr.bindMemory(to: CChar.self)
                strncpy(buffer.baseAddress!, cString, length)
                buffer[Int(length)] = 0
            }
        }
        return accelerator
    }

    internal init(_ cAccelerator: native_keyboard_accelerator_t) {
        self.modifiers = AcceleratorModifier(rawValue: cAccelerator.modifiers)
        self.key = withUnsafePointer(to: cAccelerator.key) { ptr in
            String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
    }
}

/// Menu item selection event
public struct MenuItemSelectedEvent {
    public let itemId: Int
    public let itemText: String

    internal init(_ cEvent: native_menu_item_selected_event_t) {
        self.itemId = Int(cEvent.item_id)
        self.itemText = withUnsafePointer(to: cEvent.item_text) { ptr in
            String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
    }
}

/// Menu item state changed event
public struct MenuItemStateChangedEvent {
    public let itemId: Int
    public let isChecked: Bool

    internal init(_ cEvent: native_menu_item_state_changed_event_t) {
        self.itemId = Int(cEvent.item_id)
        self.isChecked = cEvent.checked
    }
}

/// Represents a menu item
public class MenuItem {
    internal let handle: native_menu_item_t
    private var clickCallback: ((MenuItemSelectedEvent) -> Void)?
    private var stateChangedCallback: ((MenuItemStateChangedEvent) -> Void)?

    /// Unique identifier for this menu item
    public var id: Int {
        return Int(native_menu_item_get_id(handle))
    }

    /// Create a new menu item
    public init(text: String = "", type: MenuItemType = .normal) {
        self.handle = native_menu_item_create(text, native_menu_item_type_t(UInt32(type.rawValue)))!
        setupCallbacks()
    }

    /// Create a separator menu item
    public static func createSeparator() -> MenuItem {
        let item = MenuItem.__createFromHandle(native_menu_item_create_separator()!)
        return item
    }

    internal init(handle: native_menu_item_t) {
        self.handle = handle
        setupCallbacks()
    }

    internal static func __createFromHandle(_ handle: native_menu_item_t) -> MenuItem {
        return MenuItem(handle: handle)
    }

    deinit {
        native_menu_item_destroy(handle)
    }

    private func setupCallbacks() {
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        native_menu_item_set_on_click(
            handle,
            { event, userData in
                guard let event = event, let userData = userData else { return }
                let menuItem = Unmanaged<MenuItem>.fromOpaque(userData).takeUnretainedValue()
                let swiftEvent = MenuItemSelectedEvent(event.pointee)
                menuItem.clickCallback?(swiftEvent)
            }, selfPtr)

        native_menu_item_set_on_state_changed(
            handle,
            { event, userData in
                guard let event = event, let userData = userData else { return }
                let menuItem = Unmanaged<MenuItem>.fromOpaque(userData).takeUnretainedValue()
                let swiftEvent = MenuItemStateChangedEvent(event.pointee)
                menuItem.stateChangedCallback?(swiftEvent)
            }, selfPtr)
    }

    /// Get the type of this menu item
    public var type: MenuItemType {
        let cType = native_menu_item_get_type(handle)
        return MenuItemType(rawValue: Int32(cType.rawValue)) ?? .normal
    }

    /// Get or set the display text for the menu item
    public var text: String {
        get {
            var buffer = [CChar](repeating: 0, count: 256)
            let length = native_menu_item_get_text(handle, &buffer, 256)
            if length >= 0 {
                let nullIndex = buffer.firstIndex(of: 0) ?? buffer.endIndex
                let bytes = buffer[..<nullIndex].map { UInt8(bitPattern: $0) }
                return String(decoding: bytes, as: UTF8.self)
            }
            return ""
        }
        set {
            native_menu_item_set_text(handle, newValue)
        }
    }

    /// Get or set the icon for the menu item
    public var icon: String {
        get {
            var buffer = [CChar](repeating: 0, count: 512)
            let length = native_menu_item_get_icon(handle, &buffer, 512)
            if length >= 0 {
                let nullIndex = buffer.firstIndex(of: 0) ?? buffer.endIndex
                let bytes = buffer[..<nullIndex].map { UInt8(bitPattern: $0) }
                return String(decoding: bytes, as: UTF8.self)
            }
            return ""
        }
        set {
            native_menu_item_set_icon(handle, newValue)
        }
    }

    /// Get or set the tooltip text for the menu item
    public var tooltip: String {
        get {
            var buffer = [CChar](repeating: 0, count: 256)
            let length = native_menu_item_get_tooltip(handle, &buffer, 256)
            if length >= 0 {
                let nullIndex = buffer.firstIndex(of: 0) ?? buffer.endIndex
                let bytes = buffer[..<nullIndex].map { UInt8(bitPattern: $0) }
                return String(decoding: bytes, as: UTF8.self)
            }
            return ""
        }
        set {
            native_menu_item_set_tooltip(handle, newValue)
        }
    }

    /// Get or set the keyboard accelerator for the menu item
    public var accelerator: KeyboardAccelerator? {
        get {
            var cAccelerator = native_keyboard_accelerator_t()
            return native_menu_item_get_accelerator(handle, &cAccelerator)
                ? KeyboardAccelerator(cAccelerator) : nil
        }
        set {
            if let accelerator = newValue {
                var cAccelerator = accelerator.cStruct
                native_menu_item_set_accelerator(handle, &cAccelerator)
            } else {
                native_menu_item_remove_accelerator(handle)
            }
        }
    }

    /// Remove the keyboard accelerator from the menu item
    public func removeAccelerator() {
        native_menu_item_remove_accelerator(handle)
    }

    /// Get or set whether the menu item is enabled
    public var isEnabled: Bool {
        get { return native_menu_item_is_enabled(handle) }
        set { native_menu_item_set_enabled(handle, newValue) }
    }

    /// Get or set whether the menu item is visible
    public var isVisible: Bool {
        get { return native_menu_item_is_visible(handle) }
        set { native_menu_item_set_visible(handle, newValue) }
    }

    /// Get or set the checked state of a checkbox or radio menu item
    public var isChecked: Bool {
        get { return native_menu_item_is_checked(handle) }
        set { native_menu_item_set_checked(handle, newValue) }
    }

    /// Get or set the radio group ID for radio menu items
    public var radioGroup: Int {
        get { return Int(native_menu_item_get_radio_group(handle)) }
        set { native_menu_item_set_radio_group(handle, Int32(newValue)) }
    }

    /// Get or set the submenu for this menu item
    public var submenu: Menu? {
        get {
            let submenuHandle = native_menu_item_get_submenu(handle)
            return submenuHandle != nil ? Menu.__createFromHandle(submenuHandle!) : nil
        }
        set {
            if let submenu = newValue {
                native_menu_item_set_submenu(handle, submenu.handle)
            } else {
                native_menu_item_remove_submenu(handle)
            }
        }
    }

    /// Remove the submenu from this menu item
    public func removeSubmenu() {
        native_menu_item_remove_submenu(handle)
    }

    /// Set a callback function for menu item click events
    public func onClick(_ callback: @escaping (MenuItemSelectedEvent) -> Void) {
        self.clickCallback = callback
    }

    /// Set a callback function for menu item state change events
    public func onStateChanged(_ callback: @escaping (MenuItemStateChangedEvent) -> Void) {
        self.stateChangedCallback = callback
    }

    /// Programmatically trigger this menu item
    @discardableResult
    public func trigger() -> Bool {
        return native_menu_item_trigger(handle)
    }
}

/// Represents a menu
public class Menu {
    internal let handle: native_menu_t
    private var willShowCallback: (() -> Void)?
    private var didHideCallback: (() -> Void)?

    /// Unique identifier for this menu
    public var id: Int {
        return Int(native_menu_get_id(handle))
    }

    /// Create a new menu
    public init() {
        self.handle = native_menu_create()!
        setupCallbacks()
    }

    internal init(handle: native_menu_t) {
        self.handle = handle
        setupCallbacks()
    }

    internal static func __createFromHandle(_ handle: native_menu_t) -> Menu {
        return Menu(handle: handle)
    }

    deinit {
        native_menu_destroy(handle)
    }

    private func setupCallbacks() {
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        native_menu_set_on_will_show(
            handle,
            { menuId, userData in
                guard let userData = userData else { return }
                let menu = Unmanaged<Menu>.fromOpaque(userData).takeUnretainedValue()
                menu.willShowCallback?()
            }, selfPtr)

        native_menu_set_on_did_hide(
            handle,
            { menuId, userData in
                guard let userData = userData else { return }
                let menu = Unmanaged<Menu>.fromOpaque(userData).takeUnretainedValue()
                menu.didHideCallback?()
            }, selfPtr)
    }

    /// Add a menu item to the end of the menu
    public func addItem(_ item: MenuItem) {
        native_menu_add_item(handle, item.handle)
    }

    /// Insert a menu item at a specific position
    public func insertItem(_ item: MenuItem, at index: Int) {
        native_menu_insert_item(handle, item.handle, size_t(index))
    }

    /// Remove a menu item from the menu
    @discardableResult
    public func removeItem(_ item: MenuItem) -> Bool {
        return native_menu_remove_item(handle, item.handle)
    }

    /// Remove a menu item by its ID
    @discardableResult
    public func removeItem(withId itemId: Int) -> Bool {
        return native_menu_remove_item_by_id(handle, native_menu_item_id_t(itemId))
    }

    /// Remove a menu item at a specific position
    @discardableResult
    public func removeItem(at index: Int) -> Bool {
        return native_menu_remove_item_at(handle, size_t(index))
    }

    /// Remove all menu items from the menu
    public func clear() {
        native_menu_clear(handle)
    }

    /// Add a separator line to the menu
    public func addSeparator() {
        native_menu_add_separator(handle)
    }

    /// Insert a separator at a specific position
    public func insertSeparator(at index: Int) {
        native_menu_insert_separator(handle, size_t(index))
    }

    /// Get the number of items in the menu
    public var itemCount: Int {
        return Int(native_menu_get_item_count(handle))
    }

    /// Get a menu item by its position
    public func item(at index: Int) -> MenuItem? {
        let itemHandle = native_menu_get_item_at(handle, size_t(index))
        return itemHandle != nil ? MenuItem.__createFromHandle(itemHandle!) : nil
    }

    /// Get a menu item by its ID
    public func item(withId itemId: Int) -> MenuItem? {
        let itemHandle = native_menu_get_item_by_id(handle, native_menu_item_id_t(itemId))
        return itemHandle != nil ? MenuItem.__createFromHandle(itemHandle!) : nil
    }

    /// Get all menu items in the menu
    public var allItems: [MenuItem] {
        let itemList = native_menu_get_all_items(handle)
        defer { native_menu_item_list_free(itemList) }

        guard let items = itemList.items else { return [] }

        var result: [MenuItem] = []
        for i in 0..<Int(itemList.count) {
            let itemHandle = items[i]
            if let item = itemHandle {
                result.append(MenuItem.__createFromHandle(item))
            }
        }
        return result
    }

    /// Find a menu item by its text
    public func findItem(byText text: String) -> MenuItem? {
        let itemHandle = native_menu_find_item_by_text(handle, text)
        return itemHandle != nil ? MenuItem.__createFromHandle(itemHandle!) : nil
    }

    /// Display the menu as a context menu at the specified screen coordinates
    @discardableResult
    public func showAsContextMenu(at point: Point) -> Bool {
        return native_menu_show_as_context_menu(handle, point.x, point.y)
    }

    /// Display the menu as a context menu at the current cursor position
    @discardableResult
    public func showAsContextMenu() -> Bool {
        return native_menu_show_as_context_menu_default(handle)
    }

    /// Programmatically close the menu if it's currently showing
    @discardableResult
    public func close() -> Bool {
        return native_menu_close(handle)
    }

    /// Check if the menu is currently visible
    public var isVisible: Bool {
        return native_menu_is_visible(handle)
    }

    /// Get or set whether the menu is enabled
    public var isEnabled: Bool {
        get { return native_menu_is_enabled(handle) }
        set { native_menu_set_enabled(handle, newValue) }
    }

    /// Set a callback function for menu open events
    public func onWillShow(_ callback: @escaping () -> Void) {
        self.willShowCallback = callback
    }

    /// Set a callback function for menu close events
    public func onDidHide(_ callback: @escaping () -> Void) {
        self.didHideCallback = callback
    }

    /// Create a standard menu item and add it to the menu
    @discardableResult
    public func createAndAddItem(text: String) -> MenuItem {
        let itemHandle = native_menu_create_and_add_item(
            handle, text, NATIVE_MENU_ITEM_TYPE_NORMAL)!
        return MenuItem.__createFromHandle(itemHandle)
    }

    /// Create a menu item with icon and add it to the menu
    @discardableResult
    public func createAndAddItem(text: String, icon: String) -> MenuItem {
        let item = createAndAddItem(text: text)
        item.icon = icon
        return item
    }

    /// Create a submenu item and add it to the menu
    @discardableResult
    public func createAndAddSubmenu(text: String, submenu: Menu) -> MenuItem {
        let itemHandle = native_menu_create_and_add_submenu(handle, text, submenu.handle)!
        return MenuItem.__createFromHandle(itemHandle)
    }
}

// MARK: - Convenience Extensions

extension MenuItem {
    /// Convenience initializer for creating menu items with common configurations
    public convenience init(
        text: String, type: MenuItemType, icon: String? = nil,
        accelerator: KeyboardAccelerator? = nil, onClick: ((MenuItemSelectedEvent) -> Void)? = nil
    ) {
        self.init(text: text, type: type)

        if let icon = icon {
            self.icon = icon
        }

        if let accelerator = accelerator {
            self.accelerator = accelerator
        }

        if let onClick = onClick {
            self.onClick(onClick)
        }
    }
}

extension Menu {
    /// Convenience method to add a simple menu item with text
    @discardableResult
    public func addItem(text: String, onClick: ((MenuItemSelectedEvent) -> Void)? = nil) -> MenuItem
    {
        let item = MenuItem(text: text)
        if let onClick = onClick {
            item.onClick(onClick)
        }
        addItem(item)
        return item
    }

    /// Convenience method to add a checkbox menu item
    @discardableResult
    public func addCheckboxItem(
        text: String, checked: Bool = false,
        onStateChanged: ((MenuItemStateChangedEvent) -> Void)? = nil
    ) -> MenuItem {
        let item = MenuItem(text: text, type: .checkbox)
        item.isChecked = checked
        if let onStateChanged = onStateChanged {
            item.onStateChanged(onStateChanged)
        }
        addItem(item)
        return item
    }

    /// Convenience method to add a radio menu item
    @discardableResult
    public func addRadioItem(
        text: String, groupId: Int, checked: Bool = false,
        onStateChanged: ((MenuItemStateChangedEvent) -> Void)? = nil
    ) -> MenuItem {
        let item = MenuItem(text: text, type: .radio)
        item.radioGroup = groupId
        item.isChecked = checked
        if let onStateChanged = onStateChanged {
            item.onStateChanged(onStateChanged)
        }
        addItem(item)
        return item
    }

    /// Convenience method to add a submenu
    @discardableResult
    public func addSubmenu(text: String, configure: ((Menu) -> Void)? = nil) -> MenuItem {
        let submenu = Menu()
        configure?(submenu)
        return createAndAddSubmenu(text: text, submenu: submenu)
    }
}
