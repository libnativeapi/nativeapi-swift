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

// MARK: - MenuItem Class

/// MenuItem represents a single item in a menu.
public class MenuItem: BaseEventEmitter, NativeHandleWrapper {
    public typealias NativeHandleType = native_menu_item_t
    
    public let nativeHandle: native_menu_item_t
    private var eventListeners: [Int32: Any] = [:]
    
    // Static map to track instances by their native handle address
    // Note: Access is protected by instancesLock
    private nonisolated(unsafe) static var instances: [Int: MenuItem] = [:]
    private static let instancesLock = NSLock()

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
        
        // Register event listeners
        setupEventListeners()
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
        
        setupEventListeners()
    }
    
    private func setupEventListeners() {
        // Register listeners for each event type with native callbacks
        registerNativeListeners()
    }
    
    private func registerNativeListeners() {
        // Register clicked event
        let clickedListenerId = native_menu_item_add_listener(
            nativeHandle,
            NATIVE_MENU_ITEM_EVENT_CLICKED,
            MenuItem.clickedCallback,
            nativeHandle
        )
        if clickedListenerId >= 0 {
            eventListeners[clickedListenerId] = "clicked"
        }
        
        // Register submenu opened event
        let submenuOpenedListenerId = native_menu_item_add_listener(
            nativeHandle,
            NATIVE_MENU_ITEM_EVENT_SUBMENU_OPENED,
            MenuItem.submenuOpenedCallback,
            nativeHandle
        )
        if submenuOpenedListenerId >= 0 {
            eventListeners[submenuOpenedListenerId] = "submenuOpened"
        }
        
        // Register submenu closed event
        let submenuClosedListenerId = native_menu_item_add_listener(
            nativeHandle,
            NATIVE_MENU_ITEM_EVENT_SUBMENU_CLOSED,
            MenuItem.submenuClosedCallback,
            nativeHandle
        )
        if submenuClosedListenerId >= 0 {
            eventListeners[submenuClosedListenerId] = "submenuClosed"
        }
    }
    
    // Static callback functions for native events
    private static let clickedCallback: native_menu_item_event_callback_t = { eventPtr, userDataPtr in
        guard let userDataPtr = userDataPtr else { return }
        let handleAddress = Int(bitPattern: userDataPtr)
        
        instancesLock.lock()
        guard let instance = instances[handleAddress] else {
            instancesLock.unlock()
            return
        }
        instancesLock.unlock()
        
        print("Menu item clicked: \(instance.id)")
        instance.emitSync(MenuItemClickedEvent(instance.id))
    }
    
    private static let submenuOpenedCallback: native_menu_item_event_callback_t = { eventPtr, userDataPtr in
        guard let userDataPtr = userDataPtr else { return }
        let handleAddress = Int(bitPattern: userDataPtr)
        
        instancesLock.lock()
        guard let instance = instances[handleAddress] else {
            instancesLock.unlock()
            return
        }
        instancesLock.unlock()
        
        print("Menu item submenu opened: \(instance.id)")
        instance.emitSync(MenuItemSubmenuOpenedEvent(instance.id))
    }
    
    private static let submenuClosedCallback: native_menu_item_event_callback_t = { eventPtr, userDataPtr in
        guard let userDataPtr = userDataPtr else { return }
        let handleAddress = Int(bitPattern: userDataPtr)
        
        instancesLock.lock()
        guard let instance = instances[handleAddress] else {
            instancesLock.unlock()
            return
        }
        instancesLock.unlock()
        
        print("Menu item submenu closed: \(instance.id)")
        instance.emitSync(MenuItemSubmenuClosedEvent(instance.id))
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

    /// Set the submenu for this menu item.
    /// - Parameter submenu: The submenu to attach
    public func setSubmenu(_ submenu: Menu?) {
        if let submenu = submenu {
            native_menu_item_set_submenu(nativeHandle, submenu.nativeHandle)
        } else {
            native_menu_item_remove_submenu(nativeHandle)
        }
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

    /// Remove the submenu from this menu item.
    public func removeSubmenu() {
        native_menu_item_remove_submenu(nativeHandle)
    }

    /// Programmatically trigger this menu item.
    /// - Returns: true if the item was successfully triggered, false otherwise
    public func trigger() -> Bool {
        return native_menu_item_trigger(nativeHandle)
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
        
        // Remove native listeners
        for (listenerId, _) in eventListeners {
            native_menu_item_remove_listener(nativeHandle, listenerId)
        }
        eventListeners.removeAll()
        
        // Dispose event emitter
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
    private var eventListeners: [Int32: Any] = [:]
    
    // Static map to track instances by their native handle address
    // Note: Access is protected by instancesLock
    private nonisolated(unsafe) static var instances: [Int: Menu] = [:]
    private static let instancesLock = NSLock()

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
        
        setupEventListeners()
    }

    internal init(nativeMenu: native_menu_t) {
        self.nativeHandle = nativeMenu
        super.init()
        
        // Store instance in static map using handle address as key
        let handleAddress = Int(bitPattern: nativeHandle)
        Menu.instancesLock.lock()
        Menu.instances[handleAddress] = self
        Menu.instancesLock.unlock()
        
        setupEventListeners()
    }
    
    private func setupEventListeners() {
        // Register listeners for each event type with native callbacks
        registerNativeListeners()
    }
    
    private func registerNativeListeners() {
        // Register opened event
        let openedListenerId = native_menu_add_listener(
            nativeHandle,
            NATIVE_MENU_EVENT_OPENED,
            Menu.openedCallback,
            nativeHandle
        )
        if openedListenerId >= 0 {
            eventListeners[openedListenerId] = "opened"
        }
        
        // Register closed event
        let closedListenerId = native_menu_add_listener(
            nativeHandle,
            NATIVE_MENU_EVENT_CLOSED,
            Menu.closedCallback,
            nativeHandle
        )
        if closedListenerId >= 0 {
            eventListeners[closedListenerId] = "closed"
        }
    }
    
    // Static callback functions for native events
    private static let openedCallback: native_menu_event_callback_t = { eventPtr, userDataPtr in
        guard let userDataPtr = userDataPtr else { return }
        let handleAddress = Int(bitPattern: userDataPtr)
        
        instancesLock.lock()
        guard let instance = instances[handleAddress] else {
            instancesLock.unlock()
            return
        }
        instancesLock.unlock()
        
        print("Menu opened: \(instance.id)")
        instance.emitSync(MenuOpenedEvent(instance.id))
    }
    
    private static let closedCallback: native_menu_event_callback_t = { eventPtr, userDataPtr in
        guard let userDataPtr = userDataPtr else { return }
        let handleAddress = Int(bitPattern: userDataPtr)
        
        instancesLock.lock()
        guard let instance = instances[handleAddress] else {
            instancesLock.unlock()
            return
        }
        instancesLock.unlock()
        
        print("Menu closed: \(instance.id)")
        instance.emitSync(MenuClosedEvent(instance.id))
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

    /// Get the number of items in the menu.
    /// - Returns: The total number of menu items (including separators)
    public var itemCount: Int {
        return Int(native_menu_get_item_count(nativeHandle))
    }

    /// Display the menu as a context menu at the specified screen coordinates.
    /// - Parameters:
    ///   - x: The x-coordinate in screen coordinates where to show the menu
    ///   - y: The y-coordinate in screen coordinates where to show the menu
    /// - Returns: true if the menu was successfully shown, false otherwise
    @discardableResult
    public func open(at x: Double? = nil, y: Double? = nil) -> Bool {
        if let x = x, let y = y {
            return native_menu_open_at(nativeHandle, x, y)
        } else {
            return native_menu_open(nativeHandle)
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
        
        // Remove native listeners
        for (listenerId, _) in eventListeners {
            native_menu_remove_listener(nativeHandle, listenerId)
        }
        eventListeners.removeAll()
        
        // Dispose event emitter
        disposeEventEmitter()
        
        // Destroy native handle
        native_menu_destroy(nativeHandle)
    }
}