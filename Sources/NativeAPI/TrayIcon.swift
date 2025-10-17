import CNativeAPI
import Foundation

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
    private var eventListeners: [Int32: Any] = [:]

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
        setupEventListeners()
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
        setupEventListeners()
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
        setupEventListeners()
    }
    
    private func setupEventListeners() {
        // Register listeners for each event type with native callbacks
        registerNativeListeners()
    }
    
    private func registerNativeListeners() {
        // Register clicked event
        let clickedListenerId = native_tray_icon_add_listener(
            nativeHandle,
            NATIVE_TRAY_ICON_EVENT_CLICKED,
            TrayIcon.clickedCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )
        if clickedListenerId >= 0 {
            eventListeners[clickedListenerId] = "clicked"
        }
        
        // Register right clicked event
        let rightClickedListenerId = native_tray_icon_add_listener(
            nativeHandle,
            NATIVE_TRAY_ICON_EVENT_RIGHT_CLICKED,
            TrayIcon.rightClickedCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )
        if rightClickedListenerId >= 0 {
            eventListeners[rightClickedListenerId] = "rightClicked"
        }
        
        // Register double clicked event
        let doubleClickedListenerId = native_tray_icon_add_listener(
            nativeHandle,
            NATIVE_TRAY_ICON_EVENT_DOUBLE_CLICKED,
            TrayIcon.doubleClickedCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )
        if doubleClickedListenerId >= 0 {
            eventListeners[doubleClickedListenerId] = "doubleClicked"
        }
    }
    
    // Static callback functions for native events
    private static let clickedCallback: native_tray_icon_event_callback_t = { eventPtr, userDataPtr in
        guard let userDataPtr = userDataPtr else { return }
        let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userDataPtr).takeUnretainedValue()
        print("Tray icon clicked")
        trayIcon.emitSync(TrayIconClickedEvent())
    }
    
    private static let rightClickedCallback: native_tray_icon_event_callback_t = { eventPtr, userDataPtr in
        guard let userDataPtr = userDataPtr else { return }
        let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userDataPtr).takeUnretainedValue()
        print("Tray icon right clicked")
        trayIcon.emitSync(TrayIconRightClickedEvent())
    }
    
    private static let doubleClickedCallback: native_tray_icon_event_callback_t = { eventPtr, userDataPtr in
        guard let userDataPtr = userDataPtr else { return }
        let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userDataPtr).takeUnretainedValue()
        print("Tray icon double clicked")
        trayIcon.emitSync(TrayIconDoubleClickedEvent())
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
    /// - Parameter at: The position in screen coordinates where to show the menu
    /// - Returns: true if the menu was successfully shown, false otherwise
    ///
    /// Note: If no context menu has been set via contextMenu, this method
    /// will return false. The coordinates are in screen/global coordinates,
    /// not relative to any window.
    ///
    /// Example:
    /// ```swift
    /// // Show context menu near the tray icon
    /// if let bounds = trayIcon.bounds {
    ///     let position = Point(x: bounds.x, y: bounds.y + bounds.height)
    ///     trayIcon.openContextMenu(at: position)
    /// }
    /// ```
    public func openContextMenu(at: Point? = nil) -> Bool {
        if let at = at {
            return native_tray_icon_open_context_menu_at(nativeHandle, at.x, at.y)
        } else {
            return native_tray_icon_open_context_menu(nativeHandle)
        }
    }

    /// Close the context menu if it's currently showing.
    public func closeContextMenu() {
        native_tray_icon_close_context_menu(nativeHandle)
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
        // Remove native listeners
        for (listenerId, _) in eventListeners {
            native_tray_icon_remove_listener(nativeHandle, listenerId)
        }
        eventListeners.removeAll()
        
        // Dispose context menu if it exists
        if let contextMenu = contextMenu {
            contextMenu.dispose()
        }
        
        // Dispose event emitter
        disposeEventEmitter()
        
        // Destroy native handle
        native_tray_icon_destroy(nativeHandle)
    }
}