import CNativeAPI
import Foundation

/// Defines how the context menu is triggered for a tray icon.
///
/// This enum specifies which mouse interactions should display the tray icon's
/// context menu. The values align with tray icon event types for consistency.
public enum ContextMenuTrigger: Int32, CaseIterable {
    /// Context menu is not automatically triggered by mouse events.
    ///
    /// The application must call openContextMenu() explicitly to display the menu.
    /// Use this when you want full control over when the menu appears.
    case none = 0
    
    /// Context menu is triggered on TrayIconClickedEvent.
    ///
    /// Automatically opens the context menu when the tray icon is left-clicked.
    /// This is common on some Linux desktop environments.
    case clicked = 1
    
    /// Context menu is triggered on TrayIconRightClickedEvent.
    ///
    /// Automatically opens the context menu when the tray icon is right-clicked.
    /// This follows the convention on Windows and most desktop environments.
    case rightClicked = 2
    
    /// Context menu is triggered on TrayIconDoubleClickedEvent.
    ///
    /// Automatically opens the context menu when the tray icon is double-clicked.
    /// Less common but useful for applications that use single-click for another action.
    case doubleClicked = 3
    
    internal var nativeValue: native_context_menu_trigger_t {
        switch self {
        case .none: return NATIVE_CONTEXT_MENU_TRIGGER_NONE
        case .clicked: return NATIVE_CONTEXT_MENU_TRIGGER_CLICKED
        case .rightClicked: return NATIVE_CONTEXT_MENU_TRIGGER_RIGHT_CLICKED
        case .doubleClicked: return NATIVE_CONTEXT_MENU_TRIGGER_DOUBLE_CLICKED
        }
    }
    
    internal init(nativeValue: native_context_menu_trigger_t) {
        switch nativeValue {
        case NATIVE_CONTEXT_MENU_TRIGGER_NONE: self = .none
        case NATIVE_CONTEXT_MENU_TRIGGER_CLICKED: self = .clicked
        case NATIVE_CONTEXT_MENU_TRIGGER_RIGHT_CLICKED: self = .rightClicked
        case NATIVE_CONTEXT_MENU_TRIGGER_DOUBLE_CLICKED: self = .doubleClicked
        default: self = .none
        }
    }
}

/// TrayIcon represents a system tray icon (notification area icon).
///
/// This class provides a cross-platform interface for creating and managing
/// system tray icons. System tray icons appear in the notification area of
/// the desktop and provide quick access to application functionality through
/// context menus and click events.
///
/// The class supports:
/// - Setting custom icons (including base64-encoded images)
/// - Displaying text titles and tooltips
/// - Context menus for user interaction
/// - Event emission for mouse clicks (TrayIconClickedEvent, TrayIconRightClickedEvent, TrayIconDoubleClickedEvent)
/// - Visibility control
///
/// Example:
/// ```swift
/// // Create a tray icon
/// let trayIcon = TrayIcon()
/// trayIcon.icon = Image.fromFile("path/to/icon.png")
/// trayIcon.tooltip = "My Application"
///
/// // Set up event listeners
/// trayIcon.onClicked { event in
///     // Handle click events
///     print("Tray icon clicked")
/// }
///
/// trayIcon.onRightClicked { event in
///     // Handle right click - show context menu
///     trayIcon.openContextMenu()
/// }
///
/// // Set up a context menu
/// let menu = Menu()
/// let exitItem = MenuItem("Exit")
/// menu.addItem(exitItem)
/// trayIcon.contextMenu = menu
///
/// // Show the tray icon
/// trayIcon.isVisible = true
/// ```
public class TrayIcon: BaseEventEmitter, NativeHandleWrapper {
    public typealias NativeHandleType = native_tray_icon_t

    public let nativeHandle: native_tray_icon_t

    // Store listener IDs for cleanup
    private var clickedListenerId: Int32?
    private var rightClickedListenerId: Int32?
    private var doubleClickedListenerId: Int32?

    // Static map to track instances by their native handle address
    // Note: Access is protected by instancesLock
    private nonisolated(unsafe) static var instances: [Int: TrayIcon] = [:]
    private static let instancesLock = NSLock()

    // Static callbacks for event handling
    // Note: nonisolated(unsafe) is necessary because these callbacks are called from C/C++ code
    // which may be running on any thread. The callbacks themselves acquire locks before accessing instances.
    private nonisolated(unsafe) static var clickedCallback: native_tray_icon_event_callback_t?
    private nonisolated(unsafe) static var rightClickedCallback: native_tray_icon_event_callback_t?
    private nonisolated(unsafe) static var doubleClickedCallback: native_tray_icon_event_callback_t?
    private nonisolated(unsafe) static var callbacksInitialized = false

    /// Unique identifier for this tray icon
    public var id: Int {
        return Int(native_tray_icon_get_id(nativeHandle))
    }

    /// Default constructor for TrayIcon.
    ///
    /// Creates a new tray icon instance with default settings.
    /// The icon will not be visible until isVisible is set to true.
    public override init() {
        guard let nativeHandle = native_tray_icon_create() else {
            fatalError("Failed to create tray icon")
        }
        self.nativeHandle = nativeHandle
        super.init()

        // Store instance in static map using handle address as key
        let handleAddress = Int(bitPattern: nativeHandle)
        TrayIcon.instancesLock.lock()
        TrayIcon.instances[handleAddress] = self
        TrayIcon.instancesLock.unlock()
    }

    /// Constructor that wraps an existing platform-specific tray icon.
    ///
    /// This constructor is typically used internally by the TrayManager
    /// to wrap existing system tray icons.
    ///
    /// - Parameter nativeHandle: Pointer to the platform-specific tray icon object
    internal init?(nativeHandle: native_tray_icon_t?) {
        guard let nativeHandle = nativeHandle else { return nil }
        self.nativeHandle = nativeHandle
        super.init()

        // Store instance in static map using handle address as key
        let handleAddress = Int(bitPattern: nativeHandle)
        TrayIcon.instancesLock.lock()
        TrayIcon.instances[handleAddress] = self
        TrayIcon.instancesLock.unlock()
    }

    /// Constructor that wraps an existing native platform object.
    ///
    /// This constructor is typically used internally by the TrayManager
    /// to wrap existing system tray icons.
    ///
    /// - Parameter tray: Pointer to the platform-specific tray icon object
    public init?(tray: UnsafeMutableRawPointer?) {
        guard let tray = tray else { return nil }
        guard let nativeHandle = native_tray_icon_create_from_native(tray) else { return nil }
        self.nativeHandle = nativeHandle
        super.init()

        // Store instance in static map using handle address as key
        let handleAddress = Int(bitPattern: nativeHandle)
        TrayIcon.instancesLock.lock()
        TrayIcon.instances[handleAddress] = self
        TrayIcon.instancesLock.unlock()
    }

    override open func startEventListening() {
        // Initialize callbacks once
        if !TrayIcon.callbacksInitialized {
            TrayIcon.clickedCallback = { eventPtr, userDataPtr in
                guard let userDataPtr = userDataPtr else { return }
                let handleAddress = Int(bitPattern: userDataPtr)

                TrayIcon.instancesLock.lock()
                guard let instance = TrayIcon.instances[handleAddress] else {
                    TrayIcon.instancesLock.unlock()
                    return
                }
                TrayIcon.instancesLock.unlock()

                print("Tray icon clicked")
                instance.emitSync(TrayIconClickedEvent())
            }

            TrayIcon.rightClickedCallback = { eventPtr, userDataPtr in
                guard let userDataPtr = userDataPtr else { return }
                let handleAddress = Int(bitPattern: userDataPtr)

                TrayIcon.instancesLock.lock()
                guard let instance = TrayIcon.instances[handleAddress] else {
                    TrayIcon.instancesLock.unlock()
                    return
                }
                TrayIcon.instancesLock.unlock()

                print("Tray icon right clicked")
                instance.emitSync(TrayIconRightClickedEvent())
            }

            TrayIcon.doubleClickedCallback = { eventPtr, userDataPtr in
                guard let userDataPtr = userDataPtr else { return }
                let handleAddress = Int(bitPattern: userDataPtr)

                TrayIcon.instancesLock.lock()
                guard let instance = TrayIcon.instances[handleAddress] else {
                    TrayIcon.instancesLock.unlock()
                    return
                }
                TrayIcon.instancesLock.unlock()

                print("Tray icon double clicked")
                instance.emitSync(TrayIconDoubleClickedEvent())
            }

            TrayIcon.callbacksInitialized = true
        }

        // Register listeners for each event type with native callbacks and store IDs
        clickedListenerId = native_tray_icon_add_listener(
            nativeHandle,
            NATIVE_TRAY_ICON_EVENT_CLICKED,
            TrayIcon.clickedCallback!,
            nativeHandle
        )

        rightClickedListenerId = native_tray_icon_add_listener(
            nativeHandle,
            NATIVE_TRAY_ICON_EVENT_RIGHT_CLICKED,
            TrayIcon.rightClickedCallback!,
            nativeHandle
        )

        doubleClickedListenerId = native_tray_icon_add_listener(
            nativeHandle,
            NATIVE_TRAY_ICON_EVENT_DOUBLE_CLICKED,
            TrayIcon.doubleClickedCallback!,
            nativeHandle
        )
    }

    override open func stopEventListening() {
        // Remove native listeners using stored IDs
        if let listenerId = clickedListenerId {
            native_tray_icon_remove_listener(nativeHandle, listenerId)
            clickedListenerId = nil
        }
        if let listenerId = rightClickedListenerId {
            native_tray_icon_remove_listener(nativeHandle, listenerId)
            rightClickedListenerId = nil
        }
        if let listenerId = doubleClickedListenerId {
            native_tray_icon_remove_listener(nativeHandle, listenerId)
            doubleClickedListenerId = nil
        }
    }

    /// The title text of this tray icon
    public var title: String? {
        get {
            guard let titlePtr = native_tray_icon_get_title(nativeHandle) else {
                return nil
            }
            let title = String(cString: titlePtr)
            free_c_str(titlePtr)
            return title
        }
        set {
            native_tray_icon_set_title(nativeHandle, newValue)
        }
    }

    /// The tooltip text of this tray icon
    public var tooltip: String? {
        get {
            guard let tooltipPtr = native_tray_icon_get_tooltip(nativeHandle) else {
                return nil
            }
            let tooltip = String(cString: tooltipPtr)
            free_c_str(tooltipPtr)
            return tooltip
        }
        set {
            native_tray_icon_set_tooltip(nativeHandle, newValue)
        }
    }

    /// The icon image for the tray icon
    public var icon: Image? {
        get {
            guard let iconHandle = native_tray_icon_get_icon(nativeHandle) else {
                return nil
            }
            return Image(nativeHandle: iconHandle) { _ in
                // Don't destroy the icon handle as it's owned by the tray icon
            }
        }
        set {
            native_tray_icon_set_icon(nativeHandle, newValue?.nativeHandle)
        }
    }

    /// The context menu for the tray icon
    public var contextMenu: Menu? {
        get {
            guard let menuHandle = native_tray_icon_get_context_menu(nativeHandle) else {
                return nil
            }
            return Menu(nativeMenu: menuHandle)
        }
        set {
            native_tray_icon_set_context_menu(nativeHandle, newValue?.nativeHandle)
        }
    }

    /// Get or set the context menu trigger behavior.
    ///
    /// Determines which mouse interactions will automatically display the
    /// context menu. By default, the trigger is set to None, requiring
    /// explicit control via openContextMenu() or by setting a trigger mode.
    ///
    /// - Note: When set to `.none` (default), the context menu
    ///         will only appear when openContextMenu() is called explicitly, giving
    ///         you full control over menu display through event listeners.
    ///
    /// Example:
    /// ```swift
    /// // Right click shows menu (common on Windows/Linux)
    /// trayIcon.contextMenuTrigger = .rightClicked
    ///
    /// // Left click shows menu (common on some Linux environments and macOS)
    /// trayIcon.contextMenuTrigger = .clicked
    ///
    /// // Double click shows menu
    /// trayIcon.contextMenuTrigger = .doubleClicked
    ///
    /// // Manual control (default) - handle events yourself
    /// trayIcon.contextMenuTrigger = .none
    /// trayIcon.onRightClicked { _ in
    ///   // Custom logic before showing menu
    ///   trayIcon.openContextMenu()
    /// }
    /// ```
    public var contextMenuTrigger: ContextMenuTrigger {
        get {
            let nativeTrigger = native_tray_icon_get_context_menu_trigger(nativeHandle)
            return ContextMenuTrigger(nativeValue: nativeTrigger)
        }
        set {
            native_tray_icon_set_context_menu_trigger(nativeHandle, newValue.nativeValue)
        }
    }

    /// The screen bounds of this tray icon
    ///
    /// Returns the bounding rectangle of the tray icon in screen coordinates.
    /// This can be useful for positioning popup windows or dialogs relative
    /// to the tray icon.
    ///
    /// Note: The accuracy of this information varies by platform:
    /// - macOS: Precise bounds of the status item
    /// - Windows: Approximate location of the notification area
    /// - Linux: Depends on the desktop environment and system tray implementation
    public var bounds: Rect? {
        var cRect = native_rectangle_t()
        if native_tray_icon_get_bounds(nativeHandle, &cRect) {
            return Rect(cRect)
        }
        return nil
    }

    /// Whether this tray icon is currently visible
    public var isVisible: Bool {
        get {
            return native_tray_icon_is_visible(nativeHandle)
        }
        set {
            native_tray_icon_set_visible(nativeHandle, newValue)
        }
    }

    /// Programmatically display the context menu at a specified location.
    ///
    /// Shows the tray icon's context menu at the given screen coordinates.
    /// This allows for manually triggering the context menu through keyboard
    /// shortcuts, other UI events, or programmatic control.
    ///
    /// - Parameter at: The position in screen coordinates where to show the menu (ignored - using default position)
    /// - Returns: true if the menu was successfully shown, false otherwise
    ///
    /// Note: Position parameter is currently ignored. Menu is shown at default tray icon position.
    ///
    /// Example:
    /// ```swift
    /// // Show context menu
    /// trayIcon.openContextMenu()
    /// ```
    public func openContextMenu(at: Point? = nil) -> Bool {
        // TODO: Implement position-specific context menu opening in C API
        return native_tray_icon_open_context_menu(nativeHandle)
    }

    /// Close the context menu if it's currently showing.
    ///
    /// Closes the tray icon's context menu if it is currently visible.
    /// This allows for programmatic dismissal of the menu.
    ///
    /// - Returns: true if the menu was successfully closed or wasn't visible, false on error
    ///
    /// - Note: This method is useful for keyboard shortcuts or programmatic control
    ///         that needs to dismiss the context menu without user interaction.
    ///
    /// Example:
    /// ```swift
    /// // Close the context menu programmatically
    /// trayIcon.closeContextMenu()
    /// ```
    @discardableResult
    public func closeContextMenu() -> Bool {
        return native_tray_icon_close_context_menu(nativeHandle)
    }

    // MARK: - Event Handling

    /// Add event listener for tray icon clicked event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onClicked(_ handler: @escaping (TrayIconClickedEvent) -> Void) -> Int {
        return addCallbackListener(handler)
    }

    /// Add event listener for tray icon right clicked event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onRightClicked(_ handler: @escaping (TrayIconRightClickedEvent) -> Void) -> Int {
        return addCallbackListener(handler)
    }

    /// Add event listener for tray icon double clicked event
    /// - Parameter handler: The event handler closure
    /// - Returns: Listener ID that can be used to remove the listener
    @discardableResult
    public func onDoubleClicked(_ handler: @escaping (TrayIconDoubleClickedEvent) -> Void) -> Int {
        return addCallbackListener(handler)
    }

    public func dispose() {
        // Remove instance from static map
        let handleAddress = Int(bitPattern: nativeHandle)
        TrayIcon.instancesLock.lock()
        TrayIcon.instances.removeValue(forKey: handleAddress)
        TrayIcon.instancesLock.unlock()

        // Dispose context menu if it exists
        if let contextMenu = contextMenu {
            contextMenu.dispose()
        }

        // Dispose event emitter (will call stopEventListening if needed)
        disposeEventEmitter()

        // Destroy native handle
        native_tray_icon_destroy(nativeHandle)
    }
}
