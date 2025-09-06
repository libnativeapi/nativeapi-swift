import CNativeAPI
import Foundation

/// Menu item types
public enum MenuItemType: Int {
    case normal = 0
    case checkbox = 1
    case radio = 2
    case separator = 3
    case submenu = 4

    internal init(_ cType: native_menu_item_type_t) {
        switch cType {
        case NATIVE_MENU_ITEM_TYPE_NORMAL:
            self = .normal
        case NATIVE_MENU_ITEM_TYPE_CHECKBOX:
            self = .checkbox
        case NATIVE_MENU_ITEM_TYPE_RADIO:
            self = .radio
        case NATIVE_MENU_ITEM_TYPE_SEPARATOR:
            self = .separator
        case NATIVE_MENU_ITEM_TYPE_SUBMENU:
            self = .submenu
        default:
            self = .normal
        }
    }

    internal var cValue: native_menu_item_type_t {
        switch self {
        case .normal:
            return NATIVE_MENU_ITEM_TYPE_NORMAL
        case .checkbox:
            return NATIVE_MENU_ITEM_TYPE_CHECKBOX
        case .radio:
            return NATIVE_MENU_ITEM_TYPE_RADIO
        case .separator:
            return NATIVE_MENU_ITEM_TYPE_SEPARATOR
        case .submenu:
            return NATIVE_MENU_ITEM_TYPE_SUBMENU
        }
    }
}

/// Menu item states for checkboxes and radio buttons
public enum MenuItemState: Int {
    case unchecked = 0
    case checked = 1
    case mixed = 2

    internal init(_ cState: native_menu_item_state_t) {
        switch cState {
        case NATIVE_MENU_ITEM_STATE_UNCHECKED:
            self = .unchecked
        case NATIVE_MENU_ITEM_STATE_CHECKED:
            self = .checked
        case NATIVE_MENU_ITEM_STATE_MIXED:
            self = .mixed
        default:
            self = .unchecked
        }
    }

    internal var cValue: native_menu_item_state_t {
        switch self {
        case .unchecked:
            return NATIVE_MENU_ITEM_STATE_UNCHECKED
        case .checked:
            return NATIVE_MENU_ITEM_STATE_CHECKED
        case .mixed:
            return NATIVE_MENU_ITEM_STATE_MIXED
        }
    }
}

/// Keyboard accelerator modifier flags
public struct KeyboardAcceleratorModifiers: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none: KeyboardAcceleratorModifiers = []
    public static let ctrl = KeyboardAcceleratorModifiers(rawValue: 1 << 0)
    public static let alt = KeyboardAcceleratorModifiers(rawValue: 1 << 1)
    public static let shift = KeyboardAcceleratorModifiers(rawValue: 1 << 2)
    public static let meta = KeyboardAcceleratorModifiers(rawValue: 1 << 3)

    internal init(_ cModifiers: Int) {
        self.rawValue = cModifiers
    }

    internal var cValue: Int {
        return rawValue
    }
}

/// Keyboard accelerator for menu items
public class KeyboardAccelerator {
    public let key: String
    public let modifiers: KeyboardAcceleratorModifiers

    public init(key: String, modifiers: KeyboardAcceleratorModifiers = .none) {
        self.key = key
        self.modifiers = modifiers
    }

    internal init(_ cAccel: native_keyboard_accelerator_t) {
        // Convert fixed-size C array to Swift string
        let keyData = withUnsafeBytes(of: cAccel.key) { bytes in
            Array(bytes)
        }
        if let nullIndex = keyData.firstIndex(of: 0) {
            self.key = String(bytes: keyData[0..<nullIndex], encoding: .utf8) ?? ""
        } else {
            self.key = String(bytes: keyData, encoding: .utf8) ?? ""
        }
        self.modifiers = KeyboardAcceleratorModifiers(Int(cAccel.modifiers))
    }

    internal var cStruct: native_keyboard_accelerator_t {
        var cAccel = native_keyboard_accelerator_t()
        cAccel.modifiers = Int32(modifiers.cValue)
        // Copy key string to fixed-size buffer
        let keyData = key.cString(using: .utf8) ?? []
        let copyLength = min(keyData.count - 1, 63) // Leave room for null terminator

        // Use unsafe buffer pointer to copy data
        withUnsafeMutableBytes(of: &cAccel.key) { buffer in
            for i in 0..<copyLength {
                buffer[i] = UInt8(keyData[i])
            }
            buffer[copyLength] = 0 // Null terminator
        }
        return cAccel
    }
}

/// Menu item clicked event
public struct MenuItemClickedEvent {
    public let itemId: Int
    public let itemText: String
}

/// Menu item event callback type
public typealias MenuItemClickHandler = (MenuItemClickedEvent) -> Void

/// Represents a single menu item
public class MenuItem {
    private var cMenuItem: native_menu_item_t?
    private var clickHandler: MenuItemClickHandler?

    /// Unique identifier for this menu item
    public var id: Int {
        guard let cMenuItem = cMenuItem else { return 0 }
        return Int(native_menu_item_get_id(cMenuItem))
    }

    /// The type of this menu item
    public var type: MenuItemType {
        guard let cMenuItem = cMenuItem else { return .normal }
        return MenuItemType(native_menu_item_get_type(cMenuItem))
    }

    /// The display text of this menu item
    public var text: String {
        get {
            guard let cMenuItem = cMenuItem else { return "" }
            var buffer = [CChar](repeating: 0, count: 256)
            let length = native_menu_item_get_text(cMenuItem, &buffer, buffer.count)
            if length >= 0 {
                return String(cString: buffer, encoding: .utf8) ?? ""
            }
            return ""
        }
        set {
            guard let cMenuItem = cMenuItem else { return }
            native_menu_item_set_text(cMenuItem, newValue)
        }
    }

    /// Whether this menu item is enabled
    public var isEnabled: Bool {
        get {
            guard let cMenuItem = cMenuItem else { return true }
            return native_menu_item_is_enabled(cMenuItem)
        }
        set {
            guard let cMenuItem = cMenuItem else { return }
            native_menu_item_set_enabled(cMenuItem, newValue)
        }
    }

    /// Whether this menu item is visible
    public var isVisible: Bool {
        get {
            guard let cMenuItem = cMenuItem else { return true }
            return native_menu_item_is_visible(cMenuItem)
        }
        set {
            guard let cMenuItem = cMenuItem else { return }
            native_menu_item_set_visible(cMenuItem, newValue)
        }
    }

    /// The checked state for checkbox and radio items
    public var isChecked: Bool {
        get {
            guard let cMenuItem = cMenuItem else { return false }
            return native_menu_item_get_state(cMenuItem) == NATIVE_MENU_ITEM_STATE_CHECKED
        }
        set {
            guard let cMenuItem = cMenuItem else { return }
            let state: native_menu_item_state_t = newValue ? NATIVE_MENU_ITEM_STATE_CHECKED : NATIVE_MENU_ITEM_STATE_UNCHECKED
            native_menu_item_set_state(cMenuItem, state)
        }
    }

    /// Initialize a menu item with text and type
    public init(text: String = "", type: MenuItemType = .normal, icon: String? = nil, accelerator: KeyboardAccelerator? = nil) {
        let cText = text.isEmpty ? nil : text
        cMenuItem = native_menu_item_create(cText, type.cValue)

        if let icon = icon {
            native_menu_item_set_icon(cMenuItem, icon)
        }

        if let accelerator = accelerator {
            var cAccel = accelerator.cStruct
            native_menu_item_set_accelerator(cMenuItem, &cAccel)
        }
    }

    /// Create a separator menu item
    public static func separator() -> MenuItem {
        let item = MenuItem()
        item.cMenuItem = native_menu_item_create_separator()
        return item
    }

    deinit {
        if let cMenuItem = cMenuItem {
            native_menu_item_destroy(cMenuItem)
        }
    }

    /// Set click handler for this menu item
    public func onClick(_ handler: @escaping MenuItemClickHandler) {
        clickHandler = handler

        // Register C callback
        guard let cMenuItem = cMenuItem else { return }

        // Store handler in user data for C callback
        let userData = Unmanaged.passRetained(self).toOpaque()
        _ = native_menu_item_add_listener(cMenuItem, NATIVE_MENU_ITEM_EVENT_CLICKED, { (event, userData) in
            guard let event = event, let userData = userData else { return }
            let menuItem = Unmanaged<MenuItem>.fromOpaque(userData).takeUnretainedValue()

            let cEvent = event.withMemoryRebound(to: native_menu_item_clicked_event_t.self, capacity: 1) { $0.pointee }
            let itemText = withUnsafeBytes(of: cEvent.item_text) { bytes in
                let data = Array(bytes)
                if let nullIndex = data.firstIndex(of: 0) {
                    return String(bytes: data[0..<nullIndex], encoding: .utf8) ?? ""
                } else {
                    return String(bytes: data, encoding: .utf8) ?? ""
                }
            }
            let swiftEvent = MenuItemClickedEvent(
                itemId: Int(cEvent.item_id),
                itemText: itemText
            )

            menuItem.clickHandler?(swiftEvent)
        }, userData)
    }

    /// Programmatically trigger this menu item
    public func trigger() -> Bool {
        guard let cMenuItem = cMenuItem else { return false }
        return native_menu_item_trigger(cMenuItem)
    }

    /// Set the keyboard accelerator for this menu item
    public func setAccelerator(_ accelerator: KeyboardAccelerator?) {
        guard let cMenuItem = cMenuItem else { return }

        if let accelerator = accelerator {
            var cAccel = accelerator.cStruct
            native_menu_item_set_accelerator(cMenuItem, &cAccel)
        } else {
            native_menu_item_remove_accelerator(cMenuItem)
        }
    }

    /// Set the icon for this menu item
    public func setIcon(_ icon: String) {
        guard let cMenuItem = cMenuItem else { return }
        native_menu_item_set_icon(cMenuItem, icon)
    }

    /// Set the tooltip for this menu item
    public func setTooltip(_ tooltip: String) {
        guard let cMenuItem = cMenuItem else { return }
        native_menu_item_set_tooltip(cMenuItem, tooltip)
    }

    /// Get the native menu item handle (for internal use)
    internal var nativeHandle: native_menu_item_t? {
        return cMenuItem
    }
}

/// Represents a menu containing menu items
public class Menu {
    private var cMenu: native_menu_t?
    private var items: [MenuItem] = []

    /// Unique identifier for this menu
    public var id: Int {
        guard let cMenu = cMenu else { return 0 }
        return Int(native_menu_get_id(cMenu))
    }

    /// Number of items in this menu
    public var itemCount: Int {
        guard let cMenu = cMenu else { return 0 }
        return Int(native_menu_get_item_count(cMenu))
    }

    /// Whether this menu is enabled
    public var isEnabled: Bool {
        get {
            guard let cMenu = cMenu else { return true }
            return native_menu_is_enabled(cMenu)
        }
        set {
            guard let cMenu = cMenu else { return }
            native_menu_set_enabled(cMenu, newValue)
        }
    }

    /// Initialize an empty menu
    public init() {
        cMenu = native_menu_create()
    }

    deinit {
        if let cMenu = cMenu {
            native_menu_destroy(cMenu)
        }
    }

    /// Add a menu item to the end of the menu
    @discardableResult
    public func addItem(text: String, icon: String? = nil, accelerator: KeyboardAccelerator? = nil, action: MenuItemClickHandler? = nil) -> MenuItem {
        let item = MenuItem(text: text, type: .normal, icon: icon, accelerator: accelerator)
        addItem(item)
        if let action = action {
            item.onClick(action)
        }
        return item
    }

    /// Add a menu item to the end of the menu
    public func addItem(_ item: MenuItem) {
        guard let cMenu = cMenu, let cItem = item.nativeHandle else { return }
        native_menu_add_item(cMenu, cItem)
        items.append(item)
    }

    /// Add a checkbox menu item
    @discardableResult
    public func addCheckboxItem(text: String, checked: Bool = false, action: MenuItemClickHandler? = nil) -> MenuItem {
        let item = MenuItem(text: text, type: .checkbox)
        item.isChecked = checked
        addItem(item)
        if let action = action {
            item.onClick(action)
        }
        return item
    }

    /// Add a radio button menu item
    @discardableResult
    public func addRadioItem(text: String, groupId: Int, checked: Bool = false, action: MenuItemClickHandler? = nil) -> MenuItem {
        let item = MenuItem(text: text, type: .radio)
        item.isChecked = checked
        addItem(item)
        if let action = action {
            item.onClick(action)
        }
        // TODO: Set radio group
        return item
    }

    /// Add a separator to the menu
    public func addSeparator() {
        let separator = MenuItem.separator()
        addItem(separator)
    }

    /// Remove all items from the menu
    public func clear() {
        guard let cMenu = cMenu else { return }
        native_menu_clear(cMenu)
        items.removeAll()
    }

    /// Show this menu as a context menu at the specified position
    public func showAsContextMenu(at position: Point) -> Bool {
        guard let cMenu = cMenu else { return false }
        return native_menu_show_as_context_menu(cMenu, position.x, position.y)
    }

    /// Show this menu as a context menu at the current cursor position
    public func showAsContextMenu() -> Bool {
        guard let cMenu = cMenu else { return false }
        return native_menu_show_as_context_menu_default(cMenu)
    }

    /// Close the menu if it's currently showing
    public func close() -> Bool {
        guard let cMenu = cMenu else { return false }
        return native_menu_close(cMenu)
    }

    /// Check if the menu is currently visible
    public var isVisible: Bool {
        guard let cMenu = cMenu else { return false }
        return native_menu_is_visible(cMenu)
    }

    /// Get the native menu handle (for internal use)
    internal var nativeHandle: native_menu_t? {
        return cMenu
    }
}
