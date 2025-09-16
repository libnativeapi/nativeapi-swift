import CNativeAPI
import Foundation

// MARK: - Enums and Structures

/// Enumeration of different menu item types.
public enum MenuItemType: Int32, CaseIterable {
    /// Normal clickable menu item with text and optional icon.
    case normal = 0
    /// Checkable menu item that can be toggled on/off.
    case checkbox = 1
    /// Radio button menu item, part of a mutually exclusive group.
    case radio = 2
    /// Separator line between menu items.
    case separator = 3
    /// Submenu item that expands to show child items.
    case submenu = 4

    internal var nativeValue: native_menu_item_type_t {
        switch self {
        case .normal: return NATIVE_MENU_ITEM_TYPE_NORMAL
        case .checkbox: return NATIVE_MENU_ITEM_TYPE_CHECKBOX
        case .radio: return NATIVE_MENU_ITEM_TYPE_RADIO
        case .separator: return NATIVE_MENU_ITEM_TYPE_SEPARATOR
        case .submenu: return NATIVE_MENU_ITEM_TYPE_SUBMENU
        }
    }

    internal init(nativeValue: native_menu_item_type_t) {
        switch nativeValue {
        case NATIVE_MENU_ITEM_TYPE_NORMAL: self = .normal
        case NATIVE_MENU_ITEM_TYPE_CHECKBOX: self = .checkbox
        case NATIVE_MENU_ITEM_TYPE_RADIO: self = .radio
        case NATIVE_MENU_ITEM_TYPE_SEPARATOR: self = .separator
        case NATIVE_MENU_ITEM_TYPE_SUBMENU: self = .submenu
        default: self = .normal
        }
    }
}

/// State of a menu item (for checkboxes and radio buttons).
public enum MenuItemState: Int32, CaseIterable {
    /// Item is not checked/selected.
    case unchecked = 0
    /// Item is checked/selected.
    case checked = 1
    /// Item is in mixed/indeterminate state (checkboxes only).
    case mixed = 2

    internal var nativeValue: native_menu_item_state_t {
        switch self {
        case .unchecked: return NATIVE_MENU_ITEM_STATE_UNCHECKED
        case .checked: return NATIVE_MENU_ITEM_STATE_CHECKED
        case .mixed: return NATIVE_MENU_ITEM_STATE_MIXED
        }
    }

    internal init(nativeValue: native_menu_item_state_t) {
        switch nativeValue {
        case NATIVE_MENU_ITEM_STATE_UNCHECKED: self = .unchecked
        case NATIVE_MENU_ITEM_STATE_CHECKED: self = .checked
        case NATIVE_MENU_ITEM_STATE_MIXED: self = .mixed
        default: self = .unchecked
        }
    }
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
    public static let meta = AcceleratorModifier(rawValue: 1 << 3)  // Windows key on Windows, Cmd key on macOS

    internal var nativeValue: Int32 {
        return rawValue
    }

    internal init(nativeValue: Int32) {
        self.rawValue = nativeValue
    }
}

/// Keyboard accelerator for menu items.
public struct KeyboardAccelerator {
    /// Combination of modifier flags.
    public var modifiers: AcceleratorModifier
    /// The main key code (e.g., 'A', 'F1', etc.).
    public var key: String

    /// Constructor for creating keyboard accelerators.
    /// - Parameters:
    ///   - key: The main key (e.g., "A", "F1", "Enter")
    ///   - modifiers: Combination of modifier flags
    public init(_ key: String, modifiers: AcceleratorModifier = .none) {
        self.key = key
        self.modifiers = modifiers
    }

    /// Get a human-readable string representation of the accelerator.
    /// - Returns: String representation like "Ctrl+S" or "Alt+F4"
    public func toString() -> String {
        var components: [String] = []

        if modifiers.contains(.ctrl) { components.append("Ctrl") }
        if modifiers.contains(.alt) { components.append("Alt") }
        if modifiers.contains(.shift) { components.append("Shift") }
        if modifiers.contains(.meta) { components.append("Meta") }

        components.append(key)
        return components.joined(separator: "+")
    }

    internal var nativeValue: native_keyboard_accelerator_t {
        var nativeAccel = native_keyboard_accelerator_t()
        nativeAccel.modifiers = modifiers.nativeValue

        // Copy key string to C char array
        let keyData = key.cString(using: .utf8) ?? []
        let copyLength = min(keyData.count - 1, 63)  // -1 for null terminator, max 63 chars

        withUnsafeMutablePointer(to: &nativeAccel.key) { keyPtr in
            keyPtr.withMemoryRebound(to: CChar.self, capacity: 64) { charPtr in
                for i in 0..<copyLength {
                    charPtr[i] = keyData[i]
                }
                // Ensure null termination
                if copyLength < 64 {
                    charPtr[copyLength] = 0
                }
            }
        }

        return nativeAccel
    }

    internal init(nativeValue: native_keyboard_accelerator_t) {
        self.modifiers = AcceleratorModifier(nativeValue: nativeValue.modifiers)

        // Convert C char array to Swift String
        var keyValue = nativeValue.key
        let keyString = withUnsafePointer(to: &keyValue) { keyPtr in
            keyPtr.withMemoryRebound(to: CChar.self, capacity: 64) { charPtr in
                String(cString: charPtr)
            }
        }
        self.key = keyString
    }
}

// MARK: - MenuItem Class

/// MenuItem represents a single item in a menu.
public class MenuItem {
    internal let nativeItem: native_menu_item_t
    private var eventListeners: [Int32: Any] = [:]

    /// Unique identifier for this menu item.
    public var id: Int {
        return Int(native_menu_item_get_id(nativeItem))
    }

    // MARK: - Initializers

    /// Create a new menu item.
    /// - Parameters:
    ///   - text: The display text for the menu item
    ///   - type: The type of menu item to create
    public init(_ text: String = "", type: MenuItemType = .normal) {
        let nativeItem = native_menu_item_create(text, type.nativeValue)
        self.nativeItem = nativeItem!
    }

    /// Returns a menu item that is used to separate logical groups of menu commands.
    /// - Returns: A separator menu item
    public static func separator() -> MenuItem {
        let nativeItem = native_menu_item_create_separator()
        return MenuItem(nativeItem: nativeItem!)
    }

    internal init(nativeItem: native_menu_item_t) {
        self.nativeItem = nativeItem
    }

    deinit {
        native_menu_item_destroy(nativeItem)
    }

    // MARK: - Properties

    /// Get the type of this menu item.
    public func getType() -> MenuItemType {
        let nativeType = native_menu_item_get_type(nativeItem)
        return MenuItemType(nativeValue: nativeType)
    }

    /// Set the display text for the menu item.
    /// - Parameter text: The text to display
    public func setText(_ text: String) {
        native_menu_item_set_text(nativeItem, text)
    }

    /// Get the current display text of the menu item.
    /// - Returns: The current text as a string
    public func getText() -> String {
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        let result = native_menu_item_get_text(nativeItem, buffer, bufferSize)
        guard result >= 0 else { return "" }

        return String(cString: buffer)
    }

    /// Set the icon for the menu item.
    /// - Parameter icon: File path to an icon image or base64-encoded image data
    public func setIcon(_ icon: String) {
        native_menu_item_set_icon(nativeItem, icon)
    }

    /// Get the current icon of the menu item.
    /// - Returns: The current icon path or data as a string
    public func getIcon() -> String {
        let bufferSize = 2048
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        let result = native_menu_item_get_icon(nativeItem, buffer, bufferSize)
        guard result >= 0 else { return "" }

        return String(cString: buffer)
    }

    /// Set the tooltip text for the menu item.
    /// - Parameter tooltip: The tooltip text to display
    public func setTooltip(_ tooltip: String) {
        native_menu_item_set_tooltip(nativeItem, tooltip)
    }

    /// Get the current tooltip text of the menu item.
    /// - Returns: The current tooltip text as a string
    public func getTooltip() -> String {
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        let result = native_menu_item_get_tooltip(nativeItem, buffer, bufferSize)
        guard result >= 0 else { return "" }

        return String(cString: buffer)
    }

    /// Set the keyboard accelerator for the menu item.
    /// - Parameter accelerator: The keyboard accelerator to set
    public func setAccelerator(_ accelerator: KeyboardAccelerator) {
        var nativeAccel = accelerator.nativeValue
        native_menu_item_set_accelerator(nativeItem, &nativeAccel)
    }

    /// Get the current keyboard accelerator of the menu item.
    /// - Returns: The current KeyboardAccelerator, or nil if none is set
    public func getAccelerator() -> KeyboardAccelerator? {
        var nativeAccel = native_keyboard_accelerator_t()
        let hasAccelerator = native_menu_item_get_accelerator(nativeItem, &nativeAccel)

        guard hasAccelerator else { return nil }
        return KeyboardAccelerator(nativeValue: nativeAccel)
    }

    /// Remove the keyboard accelerator from the menu item.
    public func removeAccelerator() {
        native_menu_item_remove_accelerator(nativeItem)
    }

    /// Enable or disable the menu item.
    /// - Parameter enabled: true to enable the item, false to disable it
    public func setEnabled(_ enabled: Bool) {
        native_menu_item_set_enabled(nativeItem, enabled)
    }

    /// Check if the menu item is currently enabled.
    /// - Returns: true if the item is enabled, false if disabled
    public func isEnabled() -> Bool {
        return native_menu_item_is_enabled(nativeItem)
    }

    /// Show or hide the menu item.
    /// - Parameter visible: true to show the item, false to hide it
    public func setVisible(_ visible: Bool) {
        native_menu_item_set_visible(nativeItem, visible)
    }

    /// Check if the menu item is currently visible.
    /// - Returns: true if the item is visible, false if hidden
    public func isVisible() -> Bool {
        return native_menu_item_is_visible(nativeItem)
    }

    /// Set the state of a checkbox or radio menu item.
    /// - Parameter state: The desired state (unchecked, checked, or mixed)
    public func setState(_ state: MenuItemState) {
        native_menu_item_set_state(nativeItem, state.nativeValue)
    }

    /// Get the current state of a checkbox or radio menu item.
    /// - Returns: The current state (unchecked, checked, or mixed)
    public func getState() -> MenuItemState {
        let nativeState = native_menu_item_get_state(nativeItem)
        return MenuItemState(nativeValue: nativeState)
    }

    /// Set the radio group ID for radio menu items.
    /// - Parameter groupId: The radio group identifier
    public func setRadioGroup(_ groupId: Int32) {
        native_menu_item_set_radio_group(nativeItem, groupId)
    }

    /// Get the radio group ID of this menu item.
    /// - Returns: The radio group ID, or -1 if not a radio item or no group set
    public func getRadioGroup() -> Int32 {
        return native_menu_item_get_radio_group(nativeItem)
    }

    /// Set the submenu for this menu item.
    /// - Parameter submenu: The submenu to attach
    public func setSubmenu(_ submenu: Menu?) {
        if let submenu = submenu {
            native_menu_item_set_submenu(nativeItem, submenu.nativeMenu)
        } else {
            native_menu_item_remove_submenu(nativeItem)
        }
    }

    /// Get the submenu attached to this menu item.
    /// - Returns: The submenu, or nil if no submenu is attached
    public func getSubmenu() -> Menu? {
        guard let nativeSubmenu = native_menu_item_get_submenu(nativeItem) else {
            return nil
        }
        return Menu(nativeMenu: nativeSubmenu)
    }

    /// Remove the submenu from this menu item.
    public func removeSubmenu() {
        native_menu_item_remove_submenu(nativeItem)
    }

    /// Programmatically trigger this menu item.
    /// - Returns: true if the item was successfully triggered, false otherwise
    public func trigger() -> Bool {
        return native_menu_item_trigger(nativeItem)
    }

    // MARK: - Convenience Methods

    /// Set the checked state of a checkbox or radio menu item.
    /// - Parameter checked: true to check the item, false to uncheck it
    public func setChecked(_ checked: Bool) {
        setState(checked ? .checked : .unchecked)
    }

    /// Check if the menu item is currently checked.
    /// - Returns: true if the item is checked, false otherwise
    public func isChecked() -> Bool {
        return getState() == .checked
    }

    /// Toggle the checked state of a checkbox menu item.
    /// - Returns: The new checked state
    @discardableResult
    public func toggleChecked() -> Bool {
        let newState = !isChecked()
        setChecked(newState)
        return newState
    }

    // MARK: - Event Handling

    /// Event handler closure types
    public typealias MenuItemClickedHandler = (MenuItem) -> Void
    public typealias MenuItemSubmenuOpenedHandler = (MenuItem) -> Void
    public typealias MenuItemSubmenuClosedHandler = (MenuItem) -> Void

    /// Add event listener for menu item clicked event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onClicked(_ handler: @escaping MenuItemClickedHandler) -> Int32 {
        // Create a context struct to hold both the handler and self reference
        struct EventContext {
            let handler: MenuItemClickedHandler
            let menuItem: MenuItem
        }

        let contextPtr = UnsafeMutablePointer<EventContext>.allocate(capacity: 1)
        contextPtr.initialize(to: EventContext(handler: handler, menuItem: self))

        let callback: native_menu_item_event_callback_t = { eventPtr, userDataPtr in
            guard let userDataPtr = userDataPtr else { return }
            let contextPtr = userDataPtr.assumingMemoryBound(to: EventContext.self)
            let context = contextPtr.pointee

            // Call the handler with the correct MenuItem instance
            context.handler(context.menuItem)
        }

        let listenerId = native_menu_item_add_listener(
            nativeItem,
            NATIVE_MENU_ITEM_EVENT_CLICKED,
            callback,
            contextPtr
        )

        if listenerId >= 0 {
            eventListeners[listenerId] = contextPtr
        } else {
            contextPtr.deinitialize(count: 1)
            contextPtr.deallocate()
        }

        return listenerId
    }

    /// Remove event listener
    /// - Parameter listenerId: The listener ID returned by event registration
    /// - Returns: true if removed successfully, false otherwise
    @discardableResult
    public func removeListener(_ listenerId: Int32) -> Bool {
        let success = native_menu_item_remove_listener(nativeItem, listenerId)

        if success, let contextPtr = eventListeners.removeValue(forKey: listenerId) {
            // Clean up the allocated memory for event context
            if let ptr = contextPtr as? UnsafeMutableRawPointer {
                ptr.deallocate()
            }
        }

        return success
    }
}

// MARK: - Menu Class

/// Menu represents a collection of menu items.
public class Menu {
    internal let nativeMenu: native_menu_t
    private var eventListeners: [Int32: Any] = [:]

    /// Unique identifier for this menu.
    public var id: Int {
        return Int(native_menu_get_id(nativeMenu))
    }

    // MARK: - Initializers

    /// Create a new menu instance.
    public init() {
        let nativeMenu = native_menu_create()
        self.nativeMenu = nativeMenu!
    }

    internal init(nativeMenu: native_menu_t) {
        self.nativeMenu = nativeMenu
    }

    deinit {
        native_menu_destroy(nativeMenu)
    }

    // MARK: - Menu Item Management

    /// Add a menu item to the end of the menu.
    /// - Parameter item: The menu item to add
    public func addItem(_ item: MenuItem) {
        native_menu_add_item(nativeMenu, item.nativeItem)
    }

    /// Insert a menu item at a specific position.
    /// - Parameters:
    ///   - item: The menu item to insert
    ///   - index: The position where to insert the item (0-based)
    public func insertItem(_ item: MenuItem, at index: Int) {
        native_menu_insert_item(nativeMenu, item.nativeItem, index)
    }

    /// Remove a menu item from the menu.
    /// - Parameter item: The menu item to remove
    /// - Returns: true if the item was found and removed, false otherwise
    @discardableResult
    public func removeItem(_ item: MenuItem) -> Bool {
        return native_menu_remove_item(nativeMenu, item.nativeItem)
    }

    /// Remove a menu item by its ID.
    /// - Parameter itemId: The ID of the menu item to remove
    /// - Returns: true if the item was found and removed, false otherwise
    @discardableResult
    public func removeItemById(_ itemId: Int) -> Bool {
        return native_menu_remove_item_by_id(nativeMenu, Int(itemId))
    }

    /// Remove a menu item at a specific position.
    /// - Parameter index: The position of the item to remove (0-based)
    /// - Returns: true if the item was removed, false if index was out of bounds
    @discardableResult
    public func removeItemAt(_ index: Int) -> Bool {
        return native_menu_remove_item_at(nativeMenu, index)
    }

    /// Remove all menu items from the menu.
    public func clear() {
        native_menu_clear(nativeMenu)
    }

    /// Add a separator line to the menu.
    public func addSeparator() {
        native_menu_add_separator(nativeMenu)
    }

    /// Insert a separator at a specific position.
    /// - Parameter index: The position where to insert the separator (0-based)
    public func insertSeparator(at index: Int) {
        native_menu_insert_separator(nativeMenu, index)
    }

    // MARK: - Menu Item Access

    /// Get the number of items in the menu.
    /// - Returns: The total number of menu items (including separators)
    public func getItemCount() -> Int {
        return Int(native_menu_get_item_count(nativeMenu))
    }

    /// Get a menu item by its position.
    /// - Parameter index: The position of the item to retrieve (0-based)
    /// - Returns: The menu item, or nil if index is out of bounds
    public func getItemAt(_ index: Int) -> MenuItem? {
        guard let nativeItem = native_menu_get_item_at(nativeMenu, index) else {
            return nil
        }
        return MenuItem(nativeItem: nativeItem)
    }

    /// Get a menu item by its ID.
    /// - Parameter itemId: The ID of the menu item to find
    /// - Returns: The menu item, or nil if not found
    public func getItemById(_ itemId: Int) -> MenuItem? {
        guard let nativeItem = native_menu_get_item_by_id(nativeMenu, Int(itemId)) else {
            return nil
        }
        return MenuItem(nativeItem: nativeItem)
    }

    /// Get all menu items in the menu.
    /// - Returns: Array of all menu items
    public func getAllItems() -> [MenuItem] {
        let itemList = native_menu_get_all_items(nativeMenu)
        defer { native_menu_item_list_free(itemList) }

        var items: [MenuItem] = []
        for i in 0..<itemList.count {
            if let nativeItem = itemList.items?[i] {
                items.append(MenuItem(nativeItem: nativeItem))
            }
        }

        return items
    }

    /// Find a menu item by its text.
    /// - Parameter text: The text to search for
    /// - Returns: The menu item, or nil if not found
    public func findItemByText(_ text: String) -> MenuItem? {
        guard let nativeItem = native_menu_find_item_by_text(nativeMenu, text) else {
            return nil
        }
        return MenuItem(nativeItem: nativeItem)
    }

    // MARK: - Menu Display

    /// Display the menu as a context menu at the specified screen coordinates.
    /// - Parameters:
    ///   - x: The x-coordinate in screen coordinates where to show the menu
    ///   - y: The y-coordinate in screen coordinates where to show the menu
    /// - Returns: true if the menu was successfully shown, false otherwise
    @discardableResult
    public func showAsContextMenu(x: Double, y: Double) -> Bool {
        return native_menu_show_as_context_menu(nativeMenu, x, y)
    }

    /// Display the menu as a context menu at the current cursor position.
    /// - Returns: true if the menu was successfully shown, false otherwise
    @discardableResult
    public func showAsContextMenu() -> Bool {
        return native_menu_show_as_context_menu_default(nativeMenu)
    }

    /// Programmatically close the menu if it's currently showing.
    /// - Returns: true if the menu was successfully closed, false otherwise
    @discardableResult
    public func close() -> Bool {
        return native_menu_close(nativeMenu)
    }

    /// Check if the menu is currently visible.
    /// - Returns: true if the menu is currently showing, false otherwise
    public func isVisible() -> Bool {
        return native_menu_is_visible(nativeMenu)
    }

    /// Enable or disable the entire menu.
    /// - Parameter enabled: true to enable the menu, false to disable it
    public func setEnabled(_ enabled: Bool) {
        native_menu_set_enabled(nativeMenu, enabled)
    }

    /// Check if the menu is currently enabled.
    /// - Returns: true if the menu is enabled, false if disabled
    public func isEnabled() -> Bool {
        return native_menu_is_enabled(nativeMenu)
    }

    // MARK: - Event Handling

    /// Event handler closure types
    public typealias MenuOpenedHandler = (Menu) -> Void
    public typealias MenuClosedHandler = (Menu) -> Void

    /// Add event listener for menu opened event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onOpened(_ handler: @escaping MenuOpenedHandler) -> Int32 {
        // Create a context struct to hold both the handler and self reference
        struct EventContext {
            let handler: MenuOpenedHandler
            let menu: Menu
        }

        let contextPtr = UnsafeMutablePointer<EventContext>.allocate(capacity: 1)
        contextPtr.initialize(to: EventContext(handler: handler, menu: self))

        let callback: native_menu_event_callback_t = { eventPtr, userDataPtr in
            guard let userDataPtr = userDataPtr else { return }
            let contextPtr = userDataPtr.assumingMemoryBound(to: EventContext.self)
            let context = contextPtr.pointee

            // Call the handler with the correct Menu instance
            context.handler(context.menu)
        }

        let listenerId = native_menu_add_listener(
            nativeMenu,
            NATIVE_MENU_EVENT_OPENED,
            callback,
            contextPtr
        )

        if listenerId >= 0 {
            eventListeners[listenerId] = contextPtr
        } else {
            contextPtr.deinitialize(count: 1)
            contextPtr.deallocate()
        }

        return listenerId
    }

    /// Add event listener for menu closed event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onClosed(_ handler: @escaping MenuClosedHandler) -> Int32 {
        // Create a context struct to hold both the handler and self reference
        struct EventContext {
            let handler: MenuClosedHandler
            let menu: Menu
        }

        let contextPtr = UnsafeMutablePointer<EventContext>.allocate(capacity: 1)
        contextPtr.initialize(to: EventContext(handler: handler, menu: self))

        let callback: native_menu_event_callback_t = { eventPtr, userDataPtr in
            guard let userDataPtr = userDataPtr else { return }
            let contextPtr = userDataPtr.assumingMemoryBound(to: EventContext.self)
            let context = contextPtr.pointee

            // Call the handler with the correct Menu instance
            context.handler(context.menu)
        }

        let listenerId = native_menu_add_listener(
            nativeMenu,
            NATIVE_MENU_EVENT_CLOSED,
            callback,
            contextPtr
        )

        if listenerId >= 0 {
            eventListeners[listenerId] = contextPtr
        } else {
            contextPtr.deinitialize(count: 1)
            contextPtr.deallocate()
        }

        return listenerId
    }

    /// Remove event listener
    /// - Parameter listenerId: The listener ID returned by event registration
    /// - Returns: true if removed successfully, false otherwise
    @discardableResult
    public func removeListener(_ listenerId: Int32) -> Bool {
        let success = native_menu_remove_listener(nativeMenu, listenerId)

        if success, let contextPtr = eventListeners.removeValue(forKey: listenerId) {
            // Clean up the allocated memory for event context
            if let ptr = contextPtr as? UnsafeMutableRawPointer {
                ptr.deallocate()
            }
        }

        return success
    }
}
