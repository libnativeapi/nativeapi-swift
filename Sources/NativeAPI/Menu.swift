import CNativeAPI
import Foundation

// MARK: - Enums and Structures

/// Modifier key flags for keyboard accelerators that can be combined.
public struct AcceleratorModifiers: OptionSet, Sendable {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// No modifier keys
    public static let none = AcceleratorModifiers(rawValue: NATIVE_ACCELERATOR_MODIFIER_NONE.rawValue)
    /// Control key (Ctrl on Windows/Linux, Cmd on macOS)
    public static let ctrl = AcceleratorModifiers(rawValue: NATIVE_ACCELERATOR_MODIFIER_CTRL.rawValue)
    /// Alt key
    public static let alt = AcceleratorModifiers(rawValue: NATIVE_ACCELERATOR_MODIFIER_ALT.rawValue)
    /// Shift key
    public static let shift = AcceleratorModifiers(rawValue: NATIVE_ACCELERATOR_MODIFIER_SHIFT.rawValue)
    /// Meta key (Windows key on Windows, Cmd key on macOS)
    public static let meta = AcceleratorModifiers(rawValue: NATIVE_ACCELERATOR_MODIFIER_META.rawValue)
}

/// Keyboard accelerator for menu items.
///
/// Represents a keyboard shortcut that can trigger a menu item.
/// Supports modifier keys and regular keys.
///
/// Example:
/// ```swift
/// // Ctrl+S
/// let saveAccel = KeyboardAccelerator(key: "S", modifiers: .ctrl)
///
/// // Ctrl+Shift+N
/// let newAccel = KeyboardAccelerator(key: "N", modifiers: [.ctrl, .shift])
///
/// // F1
/// let helpAccel = KeyboardAccelerator(key: "F1")
/// ```
public struct KeyboardAccelerator: Sendable {
    /// Combination of modifier flags
    public var modifiers: AcceleratorModifiers
    
    /// The main key code (e.g., "A", "F1", "Enter")
    public var key: String
    
    /// Create a keyboard accelerator.
    /// - Parameters:
    ///   - key: The main key (e.g., "A", "F1", "Enter")
    ///   - modifiers: Combination of modifier flags (default: none)
    public init(key: String, modifiers: AcceleratorModifiers = .none) {
        self.key = key
        self.modifiers = modifiers
    }
    
    /// Get a human-readable string representation of the accelerator.
    /// - Returns: String representation like "Ctrl+S" or "Alt+F4"
    public func toString() -> String {
        var nativeAccel = nativeValue
        guard let cString = native_keyboard_accelerator_to_string(&nativeAccel) else {
            return ""
        }
        let result = String(cString: cString)
        free_c_str(cString)
        return result
    }
    
    internal var nativeValue: native_keyboard_accelerator_t {
        var result = native_keyboard_accelerator_t()
        result.modifiers = Int32(modifiers.rawValue)
        let keyCString = key.utf8CString
        let maxLen = min(keyCString.count - 1, 63) // -1 for null terminator, leave room for null
        if maxLen > 0 {
            keyCString.withUnsafeBufferPointer { buffer in
                let ptr = buffer.baseAddress!
                withUnsafeMutablePointer(to: &result.key) { keyPtr in
                    keyPtr.withMemoryRebound(to: CChar.self, capacity: 64) { charPtr in
                        strncpy(charPtr, ptr, maxLen)
                        charPtr[maxLen] = 0 // Ensure null termination
                    }
                }
            }
        } else {
            withUnsafeMutablePointer(to: &result.key) { keyPtr in
                keyPtr.withMemoryRebound(to: CChar.self, capacity: 64) { charPtr in
                    charPtr[0] = 0
                }
            }
        }
        return result
    }
    
    internal init(nativeValue: native_keyboard_accelerator_t) {
        self.modifiers = AcceleratorModifiers(rawValue: UInt32(nativeValue.modifiers))
        var keyBuffer: [CChar] = Array(repeating: 0, count: 64)
        withUnsafePointer(to: nativeValue.key) { keyPtr in
            keyPtr.withMemoryRebound(to: CChar.self, capacity: 64) { charPtr in
                for i in 0..<64 {
                    keyBuffer[i] = charPtr[i]
                }
            }
        }
        self.key = String(cString: keyBuffer)
    }
}

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

// MARK: - MenuItem Class

/// MenuItem represents a single item in a menu.
public class MenuItem: BaseEventEmitter, NativeHandleWrapper {
    public typealias NativeHandleType = native_menu_item_t

    public let nativeHandle: native_menu_item_t

    // Store listener IDs for cleanup
    private var clickedListenerId: Int32?
    private var submenuOpenedListenerId: Int32?
    private var submenuClosedListenerId: Int32?

    // Static map to track instances by their native handle address
    // Note: Access is protected by instancesLock
    private nonisolated(unsafe) static var instances: [Int: MenuItem] = [:]
    private static let instancesLock = NSLock()

    // Static callbacks for event handling
    // Note: nonisolated(unsafe) is necessary because these callbacks are called from C/C++ code
    // which may be running on any thread. The callbacks themselves acquire locks before accessing instances.
    private nonisolated(unsafe) static var clickedCallback: native_menu_item_event_callback_t?
    private nonisolated(unsafe) static var submenuOpenedCallback: native_menu_item_event_callback_t?
    private nonisolated(unsafe) static var submenuClosedCallback: native_menu_item_event_callback_t?
    private nonisolated(unsafe) static var callbacksInitialized = false

    /// Unique identifier for this menu item.
    public var id: Int {
        return Int(native_menu_item_get_id(nativeHandle))
    }

    // MARK: - Initializers

    /// Create a new menu item.
    /// - Parameters:
    ///   - label: The display label for the menu item
    ///   - type: The type of menu item to create
    public init(_ label: String = "", type: MenuItemType = .normal) {
        guard let nativeItem = native_menu_item_create(label, type.nativeValue) else {
            fatalError("Failed to create menu item")
        }
        self.nativeHandle = nativeItem
        super.init()

        // Store instance in static map using handle address as key
        let handleAddress = Int(bitPattern: nativeHandle)
        MenuItem.instancesLock.lock()
        MenuItem.instances[handleAddress] = self
        MenuItem.instancesLock.unlock()
    }

    /// Returns a menu item that is used to separate logical groups of menu commands.
    /// - Returns: A separator menu item
    public static func separator() -> MenuItem {
        guard let nativeItem = native_menu_item_create_separator() else {
            fatalError("Failed to create separator menu item")
        }
        return MenuItem(nativeItem: nativeItem)
    }

    internal init(nativeItem: native_menu_item_t) {
        self.nativeHandle = nativeItem
        super.init()

        // Store instance in static map using handle address as key
        let handleAddress = Int(bitPattern: nativeHandle)
        MenuItem.instancesLock.lock()
        MenuItem.instances[handleAddress] = self
        MenuItem.instancesLock.unlock()
    }

    override open func startEventListening() {
        // Initialize callbacks once
        if !MenuItem.callbacksInitialized {
            MenuItem.clickedCallback = { eventPtr, userDataPtr in
                guard let userDataPtr = userDataPtr else { return }
                let handleAddress = Int(bitPattern: userDataPtr)

                MenuItem.instancesLock.lock()
                guard let instance = MenuItem.instances[handleAddress] else {
                    MenuItem.instancesLock.unlock()
                    return
                }
                MenuItem.instancesLock.unlock()

                print("Menu item clicked: \(instance.id)")
                instance.emitSync(MenuItemClickedEvent(instance.id))
            }

            MenuItem.submenuOpenedCallback = { eventPtr, userDataPtr in
                guard let userDataPtr = userDataPtr else { return }
                let handleAddress = Int(bitPattern: userDataPtr)

                MenuItem.instancesLock.lock()
                guard let instance = MenuItem.instances[handleAddress] else {
                    MenuItem.instancesLock.unlock()
                    return
                }
                MenuItem.instancesLock.unlock()

                print("Menu item submenu opened: \(instance.id)")
                instance.emitSync(MenuItemSubmenuOpenedEvent(instance.id))
            }

            MenuItem.submenuClosedCallback = { eventPtr, userDataPtr in
                guard let userDataPtr = userDataPtr else { return }
                let handleAddress = Int(bitPattern: userDataPtr)

                MenuItem.instancesLock.lock()
                guard let instance = MenuItem.instances[handleAddress] else {
                    MenuItem.instancesLock.unlock()
                    return
                }
                MenuItem.instancesLock.unlock()

                print("Menu item submenu closed: \(instance.id)")
                instance.emitSync(MenuItemSubmenuClosedEvent(instance.id))
            }

            MenuItem.callbacksInitialized = true
        }

        // Register listeners for each event type with native callbacks and store IDs
        clickedListenerId = native_menu_item_add_listener(
            nativeHandle,
            NATIVE_MENU_ITEM_EVENT_CLICKED,
            MenuItem.clickedCallback!,
            nativeHandle
        )

        submenuOpenedListenerId = native_menu_item_add_listener(
            nativeHandle,
            NATIVE_MENU_ITEM_EVENT_SUBMENU_OPENED,
            MenuItem.submenuOpenedCallback!,
            nativeHandle
        )

        submenuClosedListenerId = native_menu_item_add_listener(
            nativeHandle,
            NATIVE_MENU_ITEM_EVENT_SUBMENU_CLOSED,
            MenuItem.submenuClosedCallback!,
            nativeHandle
        )
    }

    override open func stopEventListening() {
        // Remove native listeners using stored IDs
        if let listenerId = clickedListenerId {
            native_menu_item_remove_listener(nativeHandle, listenerId)
            clickedListenerId = nil
        }
        if let listenerId = submenuOpenedListenerId {
            native_menu_item_remove_listener(nativeHandle, listenerId)
            submenuOpenedListenerId = nil
        }
        if let listenerId = submenuClosedListenerId {
            native_menu_item_remove_listener(nativeHandle, listenerId)
            submenuClosedListenerId = nil
        }
    }

    // MARK: - Properties

    /// Get the type of this menu item.
    public var type: MenuItemType {
        let nativeType = native_menu_item_get_type(nativeHandle)
        return MenuItemType(nativeValue: nativeType)
    }

    /// Set the display label for the menu item.
    /// - Parameter label: The label to display
    public func setLabel(_ label: String) {
        native_menu_item_set_label(nativeHandle, label)
    }

    /// Get the current display label of the menu item.
    /// - Returns: The current label as a string
    public func getLabel() -> String {
        guard let labelPtr = native_menu_item_get_label(nativeHandle) else {
            return ""
        }
        let label = String(cString: labelPtr)
        free_c_str(labelPtr)
        return label
    }

    /// Get or set the label property
    public var label: String {
        get { getLabel() }
        set { setLabel(newValue) }
    }

    /// Set the icon for the menu item.
    /// - Parameter icon: Image object for the icon
    public func setIcon(_ icon: Image?) {
        native_menu_item_set_icon(nativeHandle, icon?.nativeHandle)
    }

    /// Get the current icon of the menu item.
    /// - Returns: The current icon as an Image object, or nil if none
    public func getIcon() -> Image? {
        guard let iconHandle = native_menu_item_get_icon(nativeHandle) else {
            return nil
        }
        return Image(nativeHandle: iconHandle) { _ in
            // Don't destroy the icon handle as it's owned by the menu item
        }
    }

    /// Get or set the icon property
    public var icon: Image? {
        get { getIcon() }
        set { setIcon(newValue) }
    }

    /// Set the tooltip text for the menu item.
    /// - Parameter tooltip: The tooltip text to display
    public func setTooltip(_ tooltip: String) {
        native_menu_item_set_tooltip(nativeHandle, tooltip)
    }

    /// Get the current tooltip text of the menu item.
    /// - Returns: The current tooltip text as a string
    public func getTooltip() -> String {
        guard let tooltipPtr = native_menu_item_get_tooltip(nativeHandle) else {
            return ""
        }
        let tooltip = String(cString: tooltipPtr)
        free_c_str(tooltipPtr)
        return tooltip
    }

    /// Get or set the tooltip property
    public var tooltip: String {
        get { getTooltip() }
        set { setTooltip(newValue) }
    }

    /// Get or set the state of this menu item (for checkboxes and radio buttons).
    public var state: MenuItemState {
        get {
            let nativeState = native_menu_item_get_state(nativeHandle)
            return MenuItemState(nativeValue: nativeState)
        }
        set {
            native_menu_item_set_state(nativeHandle, newValue.nativeValue)
        }
    }

    /// Get or set the radio group ID for this menu item (for radio buttons).
    public var radioGroup: Int {
        get {
            return Int(native_menu_item_get_radio_group(nativeHandle))
        }
        set {
            native_menu_item_set_radio_group(nativeHandle, Int32(newValue))
        }
    }

    /// Get or set whether this menu item is enabled.
    public var enabled: Bool {
        get {
            return native_menu_item_is_enabled(nativeHandle)
        }
        set {
            native_menu_item_set_enabled(nativeHandle, newValue)
        }
    }

    /// Set the keyboard accelerator for the menu item.
    ///
    /// The accelerator allows users to trigger the menu item using
    /// keyboard shortcuts. The accelerator is typically displayed
    /// next to the menu item label.
    ///
    /// - Parameter accelerator: The keyboard accelerator to set, or nil to remove
    ///
    /// Example:
    /// ```swift
    /// // Set Ctrl+S as accelerator
    /// item.setAccelerator(KeyboardAccelerator(key: "S", modifiers: .ctrl))
    ///
    /// // Set F1 as accelerator
    /// item.setAccelerator(KeyboardAccelerator(key: "F1"))
    ///
    /// // Set Alt+F4 as accelerator
    /// item.setAccelerator(KeyboardAccelerator(key: "F4", modifiers: .alt))
    ///
    /// // Remove accelerator
    /// item.setAccelerator(nil)
    /// ```
    public func setAccelerator(_ accelerator: KeyboardAccelerator?) {
        if let accelerator = accelerator {
            var nativeAccel = accelerator.nativeValue
            native_menu_item_set_accelerator(nativeHandle, &nativeAccel)
        } else {
            native_menu_item_set_accelerator(nativeHandle, nil)
        }
    }

    /// Get the current keyboard accelerator of the menu item.
    /// - Returns: The current KeyboardAccelerator, or nil if none is set
    public func getAccelerator() -> KeyboardAccelerator? {
        var nativeAccel = native_keyboard_accelerator_t()
        guard native_menu_item_get_accelerator(nativeHandle, &nativeAccel) else {
            return nil
        }
        return KeyboardAccelerator(nativeValue: nativeAccel)
    }

    /// Get or set the keyboard accelerator property
    public var accelerator: KeyboardAccelerator? {
        get { getAccelerator() }
        set { setAccelerator(newValue) }
    }

    /// Set the submenu for this menu item.
    /// - Parameter submenu: The submenu to attach
    public func setSubmenu(_ submenu: Menu?) {
        native_menu_item_set_submenu(nativeHandle, submenu?.nativeHandle)
    }

    /// Get the submenu attached to this menu item.
    /// - Returns: The submenu, or nil if no submenu is attached
    public func getSubmenu() -> Menu? {
        guard let nativeSubmenu = native_menu_item_get_submenu(nativeHandle) else {
            return nil
        }
        return Menu(nativeMenu: nativeSubmenu)
    }

    /// Get or set the submenu property
    public var submenu: Menu? {
        get { getSubmenu() }
        set { setSubmenu(newValue) }
    }

    /// Programmatically trigger this menu item.
    /// - Returns: true if the item was successfully triggered, false otherwise
    public func trigger() -> Bool {
        // TODO: Implement menu item triggering in C API
        return false
    }

    // MARK: - Event Handling

    /// Add event listener for menu item clicked event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onClicked(_ handler: @escaping (MenuItemClickedEvent) -> Void) -> Int {
        return addCallbackListener(handler)
    }

    /// Add event listener for menu item submenu opened event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onSubmenuOpened(_ handler: @escaping (MenuItemSubmenuOpenedEvent) -> Void) -> Int {
        return addCallbackListener(handler)
    }

    /// Add event listener for menu item submenu closed event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onSubmenuClosed(_ handler: @escaping (MenuItemSubmenuClosedEvent) -> Void) -> Int {
        return addCallbackListener(handler)
    }

    public func dispose() {
        // Remove instance from static map
        let handleAddress = Int(bitPattern: nativeHandle)
        MenuItem.instancesLock.lock()
        MenuItem.instances.removeValue(forKey: handleAddress)
        MenuItem.instancesLock.unlock()

        // Dispose event emitter (will call stopEventListening if needed)
        disposeEventEmitter()

        // Destroy native handle
        native_menu_item_destroy(nativeHandle)
    }
}

// MARK: - Menu Class

/// Menu represents a collection of menu items.
public class Menu: BaseEventEmitter, NativeHandleWrapper {
    public typealias NativeHandleType = native_menu_t

    public let nativeHandle: native_menu_t

    // Store listener IDs for cleanup
    private var openedListenerId: Int32?
    private var closedListenerId: Int32?

    // Static map to track instances by their native handle address
    // Note: Access is protected by instancesLock
    private nonisolated(unsafe) static var instances: [Int: Menu] = [:]
    private static let instancesLock = NSLock()

    // Static callbacks for event handling
    // Note: nonisolated(unsafe) is necessary because these callbacks are called from C/C++ code
    // which may be running on any thread. The callbacks themselves acquire locks before accessing instances.
    private nonisolated(unsafe) static var openedCallback: native_menu_event_callback_t?
    private nonisolated(unsafe) static var closedCallback: native_menu_event_callback_t?
    private nonisolated(unsafe) static var callbacksInitialized = false

    /// Unique identifier for this menu.
    public var id: Int {
        return Int(native_menu_get_id(nativeHandle))
    }

    // MARK: - Initializers

    /// Create a new menu instance.
    public override init() {
        guard let nativeMenu = native_menu_create() else {
            fatalError("Failed to create menu")
        }
        self.nativeHandle = nativeMenu
        super.init()

        // Store instance in static map using handle address as key
        let handleAddress = Int(bitPattern: nativeHandle)
        Menu.instancesLock.lock()
        Menu.instances[handleAddress] = self
        Menu.instancesLock.unlock()
    }

    internal init(nativeMenu: native_menu_t) {
        self.nativeHandle = nativeMenu
        super.init()

        // Store instance in static map using handle address as key
        let handleAddress = Int(bitPattern: nativeHandle)
        Menu.instancesLock.lock()
        Menu.instances[handleAddress] = self
        Menu.instancesLock.unlock()
    }

    override open func startEventListening() {
        // Initialize callbacks once
        if !Menu.callbacksInitialized {
            Menu.openedCallback = { eventPtr, userDataPtr in
                guard let userDataPtr = userDataPtr else { return }
                let handleAddress = Int(bitPattern: userDataPtr)

                Menu.instancesLock.lock()
                guard let instance = Menu.instances[handleAddress] else {
                    Menu.instancesLock.unlock()
                    return
                }
                Menu.instancesLock.unlock()

                print("Menu opened: \(instance.id)")
                instance.emitSync(MenuOpenedEvent(instance.id))
            }

            Menu.closedCallback = { eventPtr, userDataPtr in
                guard let userDataPtr = userDataPtr else { return }
                let handleAddress = Int(bitPattern: userDataPtr)

                Menu.instancesLock.lock()
                guard let instance = Menu.instances[handleAddress] else {
                    Menu.instancesLock.unlock()
                    return
                }
                Menu.instancesLock.unlock()

                print("Menu closed: \(instance.id)")
                instance.emitSync(MenuClosedEvent(instance.id))
            }

            Menu.callbacksInitialized = true
        }

        // Register listeners for each event type with native callbacks and store IDs
        openedListenerId = native_menu_add_listener(
            nativeHandle,
            NATIVE_MENU_EVENT_OPENED,
            Menu.openedCallback!,
            nativeHandle
        )

        closedListenerId = native_menu_add_listener(
            nativeHandle,
            NATIVE_MENU_EVENT_CLOSED,
            Menu.closedCallback!,
            nativeHandle
        )
    }

    override open func stopEventListening() {
        // Remove native listeners using stored IDs
        if let listenerId = openedListenerId {
            native_menu_remove_listener(nativeHandle, listenerId)
            openedListenerId = nil
        }
        if let listenerId = closedListenerId {
            native_menu_remove_listener(nativeHandle, listenerId)
            closedListenerId = nil
        }
    }

    // MARK: - Menu Item Management

    /// Add a menu item to the end of the menu.
    /// - Parameter item: The menu item to add
    public func addItem(_ item: MenuItem) {
        native_menu_add_item(nativeHandle, item.nativeHandle)
    }

    /// Insert a menu item at a specific position.
    /// - Parameters:
    ///   - item: The menu item to insert
    ///   - index: The position where to insert the item (0-based)
    public func insertItem(_ item: MenuItem, at index: Int) {
        native_menu_insert_item(nativeHandle, item.nativeHandle, index)
    }

    /// Add a separator line to the menu.
    public func addSeparator() {
        native_menu_add_separator(nativeHandle)
    }

    /// Insert a separator at a specific position.
    /// - Parameter index: The position where to insert the separator (0-based)
    public func insertSeparator(at index: Int) {
        native_menu_insert_separator(nativeHandle, index)
    }

    /// Remove a menu item from the menu.
    /// - Parameter item: The menu item to remove
    /// - Returns: true if the item was successfully removed, false otherwise
    public func removeItem(_ item: MenuItem) -> Bool {
        return native_menu_remove_item(nativeHandle, item.nativeHandle)
    }

    /// Remove a menu item by its ID.
    /// - Parameter itemId: The ID of the menu item to remove
    /// - Returns: true if the item was successfully removed, false otherwise
    public func removeItemById(_ itemId: Int) -> Bool {
        return native_menu_remove_item_by_id(nativeHandle, itemId)
    }

    /// Remove a menu item at a specific index.
    /// - Parameter index: The index of the menu item to remove (0-based)
    /// - Returns: true if the item was successfully removed, false otherwise
    public func removeItemAt(_ index: Int) -> Bool {
        return native_menu_remove_item_at(nativeHandle, index)
    }

    /// Remove all menu items from the menu.
    /// Clears the entire menu, removing all items.
    public func clear() {
        native_menu_clear(nativeHandle)
    }

    /// Get the number of items in the menu.
    /// - Returns: The total number of menu items (including separators)
    public var itemCount: Int {
        return Int(native_menu_get_item_count(nativeHandle))
    }

    /// Get a menu item at a specific position.
    /// - Parameter index: The position of the item to retrieve (0-based)
    /// - Returns: The menu item at the specified index, or nil if index is out of bounds
    public func getItemAt(_ index: Int) -> MenuItem? {
        guard let nativeItem = native_menu_get_item_at(nativeHandle, index) else {
            return nil
        }
        return MenuItem(nativeItem: nativeItem)
    }

    /// Get a menu item by its ID.
    /// - Parameter itemId: The ID of the menu item to find
    /// - Returns: The menu item with the specified ID, or nil if not found
    public func getItemById(_ itemId: Int) -> MenuItem? {
        guard let nativeItem = native_menu_get_item_by_id(nativeHandle, itemId) else {
            return nil
        }
        return MenuItem(nativeItem: nativeItem)
    }

    /// Get all menu items in the menu.
    /// - Returns: An array containing all menu items in order
    public func getAllItems() -> [MenuItem] {
        let list = native_menu_get_all_items(nativeHandle)
        defer {
            native_menu_item_list_free(list)
        }
        
        var items: [MenuItem] = []
        items.reserveCapacity(Int(list.count))
        
        guard let itemsPtr = list.items else {
            return items
        }
        
        for i in 0..<list.count {
            let itemPtr = itemsPtr.advanced(by: Int(i)).pointee
            if let itemPtr = itemPtr {
                items.append(MenuItem(nativeItem: itemPtr))
            }
        }
        
        return items
    }

    /// Display the menu as a context menu using the specified positioning strategy.
    ///
    /// Shows the menu according to the provided positioning strategy and waits for
    /// user interaction. The menu will close when the user clicks outside of it or
    /// selects an item.
    ///
    /// - Parameters:
    ///   - strategy: The positioning strategy determining where to display the menu
    ///   - placement: The placement option determining how the menu is positioned relative to the reference point (default: .bottomStart)
    /// - Returns: true if the menu was successfully opened, false otherwise
    ///
    /// Example:
    /// ```swift
    /// // Open context menu at cursor position, below the cursor
    /// menu.open(PositioningStrategy.cursorPosition(), placement: .bottomStart)
    ///
    /// // Open context menu at specific coordinates, above and centered
    /// menu.open(PositioningStrategy.absolute(Point(x: 100, y: 200)), placement: .top)
    ///
    /// // Open context menu relative to a button with offset, to the right
    /// let buttonRect = button.bounds
    /// menu.open(PositioningStrategy.relative(rect: buttonRect, offset: Point(x: 0, y: 10)), placement: .right)
    ///
    /// // Use default placement (BottomStart)
    /// menu.open(PositioningStrategy.cursorPosition())
    /// ```
    @discardableResult
    public func open(_ strategy: PositioningStrategy, placement: Placement = .bottomStart) -> Bool {
        let nativeStrategy = strategy.nativeValue
        defer {
            native_positioning_strategy_free(nativeStrategy)
        }
        
        return native_menu_open(nativeHandle, nativeStrategy, placement.nativeValue)
    }
    
    /// Display the menu as a context menu at the specified screen coordinates.
    ///
    /// Convenience method for simple absolute positioning. For more complex positioning
    /// needs, use `open(_:placement:)` with a PositioningStrategy.
    ///
    /// - Parameters:
    ///   - x: The x-coordinate in screen coordinates where to show the menu (optional, defaults to cursor position)
    ///   - y: The y-coordinate in screen coordinates where to show the menu (optional, defaults to cursor position)
    ///   - placement: The placement option determining how the menu is positioned relative to the reference point (default: .bottomStart)
    /// - Returns: true if the menu was successfully shown, false otherwise
    @discardableResult
    public func open(at x: Double? = nil, y: Double? = nil, placement: Placement = .bottomStart) -> Bool {
        if let x = x, let y = y {
            return open(PositioningStrategy.absolute(Point(x: x, y: y)), placement: placement)
        } else {
            return open(PositioningStrategy.cursorPosition(), placement: placement)
        }
    }

    /// Programmatically close the menu if it's currently showing.
    /// - Returns: true if the menu was successfully closed, false otherwise
    @discardableResult
    public func close() -> Bool {
        return native_menu_close(nativeHandle)
    }

    // MARK: - Event Handling

    /// Add event listener for menu opened event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onOpened(_ handler: @escaping (MenuOpenedEvent) -> Void) -> Int {
        return addCallbackListener(handler)
    }

    /// Add event listener for menu closed event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onClosed(_ handler: @escaping (MenuClosedEvent) -> Void) -> Int {
        return addCallbackListener(handler)
    }

    public func dispose() {
        // Remove instance from static map
        let handleAddress = Int(bitPattern: nativeHandle)
        Menu.instancesLock.lock()
        Menu.instances.removeValue(forKey: handleAddress)
        Menu.instancesLock.unlock()

        // Dispose event emitter (will call stopEventListening if needed)
        disposeEventEmitter()

        // Destroy native handle
        native_menu_destroy(nativeHandle)
    }
}
