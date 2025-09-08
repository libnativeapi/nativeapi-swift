import CNativeAPI
import Foundation

/// Tray icon clicked event
public struct TrayIconClickedEvent {
    public let trayIconId: Int
    public let button: String
}

/// Tray icon right-clicked event
public struct TrayIconRightClickedEvent {
    public let trayIconId: Int
}

/// Tray icon double-clicked event
public struct TrayIconDoubleClickedEvent {
    public let trayIconId: Int
}

/// Tray icon event callback types
public typealias TrayIconClickHandler = (TrayIconClickedEvent) -> Void
public typealias TrayIconRightClickHandler = (TrayIconRightClickedEvent) -> Void
public typealias TrayIconDoubleClickHandler = (TrayIconDoubleClickedEvent) -> Void

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
/// trayIcon.setIcon("path/to/icon.png")
/// trayIcon.setTooltip("My Application")
///
/// // Set up event listeners
/// trayIcon.onLeftClick { event in
///     // Handle left click - show/hide main window
///     if mainWindow.isVisible {
///         mainWindow.hide()
///     } else {
///         mainWindow.show()
///     }
/// }
///
/// trayIcon.onRightClick { event in
///     // Handle right click - show context menu
///     trayIcon.showContextMenu()
/// }
///
/// // Set up a context menu
/// let menu = Menu()
/// let exitItem = menu.createItem("Exit")
/// menu.addItem(exitItem)
/// trayIcon.setContextMenu(menu)
///
/// // Show the tray icon
/// _ = trayIcon.show()
/// ```
public class TrayIcon {
    private var cTrayIcon: native_tray_icon_t?
    private var leftClickHandler: TrayIconClickHandler?
    private var rightClickHandler: TrayIconRightClickHandler?
    private var doubleClickHandler: TrayIconDoubleClickHandler?
    private var contextMenu: Menu?
    private var listenerIds: [Int] = []

    /// Unique identifier for this tray icon
    public var id: Int {
        guard let cTrayIcon = cTrayIcon else { return 0 }
        return Int(native_tray_icon_get_id(cTrayIcon))
    }

    /// The title text of this tray icon
    public var title: String {
        get {
            guard let cTrayIcon = cTrayIcon else { return "" }
            var buffer = [CChar](repeating: 0, count: 256)
            let length = native_tray_icon_get_title(cTrayIcon, &buffer, buffer.count)
            if length >= 0 {
                return String(cString: buffer, encoding: .utf8) ?? ""
            }
            return ""
        }
        set {
            guard let cTrayIcon = cTrayIcon else { return }
            native_tray_icon_set_title(cTrayIcon, newValue)
        }
    }

    /// The tooltip text of this tray icon
    public var tooltip: String {
        get {
            guard let cTrayIcon = cTrayIcon else { return "" }
            var buffer = [CChar](repeating: 0, count: 256)
            let length = native_tray_icon_get_tooltip(cTrayIcon, &buffer, buffer.count)
            if length >= 0 {
                return String(cString: buffer, encoding: .utf8) ?? ""
            }
            return ""
        }
        set {
            guard let cTrayIcon = cTrayIcon else { return }
            native_tray_icon_set_tooltip(cTrayIcon, newValue)
        }
    }

    /// Whether this tray icon is currently visible
    public var isVisible: Bool {
        guard let cTrayIcon = cTrayIcon else { return false }
        return native_tray_icon_is_visible(cTrayIcon)
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
    public var bounds: Rectangle {
        guard let cTrayIcon = cTrayIcon else { return Rectangle(x: 0, y: 0, width: 0, height: 0) }
        var cRect = native_rectangle_t()
        if native_tray_icon_get_bounds(cTrayIcon, &cRect) {
            return Rectangle(x: cRect.x, y: cRect.y, width: cRect.width, height: cRect.height)
        }
        return Rectangle(x: 0, y: 0, width: 0, height: 0)
    }

    /// Default constructor for TrayIcon.
    ///
    /// Creates a new tray icon instance with default settings.
    /// The icon will not be visible until show() is called.
    public init() {
        cTrayIcon = native_tray_icon_create()
    }

    /// Constructor that wraps an existing platform-specific tray icon.
    ///
    /// This constructor is typically used internally by the TrayManager
    /// to wrap existing system tray icons.
    ///
    /// - Parameter nativeHandle: Pointer to the platform-specific tray icon object
    internal init?(nativeHandle: native_tray_icon_t?) {
        guard let nativeHandle = nativeHandle else { return nil }
        cTrayIcon = nativeHandle
    }
    
    /// Constructor that wraps an existing native platform object.
    ///
    /// This constructor is typically used internally by the TrayManager
    /// to wrap existing system tray icons.
    ///
    /// - Parameter tray: Pointer to the platform-specific tray icon object
    public init?(tray: UnsafeMutableRawPointer?) {
        guard let tray = tray else { return nil }
        cTrayIcon = native_tray_icon_create_from_native(tray)
        guard cTrayIcon != nil else { return nil }
    }

    /// Destructor for TrayIcon.
    ///
    /// Cleans up the tray icon and removes it from the system tray if visible.
    /// Also releases any associated platform-specific resources.
    deinit {
        // Remove all event listeners before destroying
        for listenerId in listenerIds {
            if let cTrayIcon = cTrayIcon {
                _ = native_tray_icon_remove_listener(cTrayIcon, Int32(listenerId))
            }
        }
        
        if let cTrayIcon = cTrayIcon {
            native_tray_icon_destroy(cTrayIcon)
        }
    }

    /// Set the icon image for the tray icon.
    ///
    /// The icon can be specified as either a file path or a base64-encoded
    /// image string. Base64 strings should be prefixed with the data URI
    /// scheme (e.g., "data:image/png;base64,iVBORw0KGgo...").
    ///
    /// - Parameter icon: File path to an icon image or base64-encoded image data
    ///
    /// Note: Supported formats depend on the platform:
    /// - macOS: PNG, JPEG, GIF, TIFF, BMP
    /// - Windows: ICO, PNG, BMP
    /// - Linux: PNG, XPM, SVG (depends on desktop environment)
    ///
    /// Example:
    /// ```swift
    /// // Using file path
    /// trayIcon.setIcon("/path/to/icon.png")
    ///
    /// // Using base64 data
    /// trayIcon.setIcon("data:image/png;base64,iVBORw0KGgo...")
    /// ```
    public func setIcon(_ icon: String) {
        guard let cTrayIcon = cTrayIcon else { return }
        native_tray_icon_set_icon(cTrayIcon, icon)
    }

    /// Set the title text for the tray icon.
    ///
    /// On platforms that support it (primarily macOS), the title text
    /// is displayed next to the icon in the status bar. On other platforms,
    /// this may be used internally for identification purposes.
    ///
    /// - Parameter title: The title text to display
    ///
    /// Note: On Windows and most Linux desktop environments, tray icons
    /// do not display title text directly.
    public func setTitle(_ title: String) {
        self.title = title
    }

    /// Set the tooltip text for the tray icon.
    ///
    /// The tooltip appears when the user hovers the mouse over the tray icon.
    /// This is supported on all platforms and is useful for providing
    /// additional context about the application's current state.
    ///
    /// - Parameter tooltip: The tooltip text to display on hover
    ///
    /// Example:
    /// ```swift
    /// trayIcon.setTooltip("MyApp - Status: Connected")
    /// ```
    public func setTooltip(_ tooltip: String) {
        self.tooltip = tooltip
    }

    /// Set the context menu for the tray icon.
    ///
    /// The context menu is displayed when the user right-clicks (or equivalent
    /// platform-specific action) on the tray icon. The menu provides the primary
    /// interface for user interaction with the application.
    ///
    /// - Parameter menu: The Menu object containing the context menu items
    ///
    /// Note: The Menu object is retained internally, so the original menu
    /// object's lifetime doesn't need to extend beyond this call.
    ///
    /// Example:
    /// ```swift
    /// let contextMenu = Menu()
    /// contextMenu.addItem(contextMenu.createItem("Show Window"))
    /// contextMenu.addSeparator()
    /// contextMenu.addItem(contextMenu.createItem("Exit"))
    /// trayIcon.setContextMenu(contextMenu)
    /// ```
    public func setContextMenu(_ menu: Menu) {
        guard let cTrayIcon = cTrayIcon else { return }
        native_tray_icon_set_context_menu(cTrayIcon, menu.nativeMenu)
        contextMenu = menu
    }
    
    /// Get the current context menu of the tray icon.
    ///
    /// - Returns: The current context Menu object, or nil if no menu is set
    public func getContextMenu() -> Menu? {
        return contextMenu
    }

    /// Show the tray icon in the system tray.
    ///
    /// Makes the tray icon visible in the system notification area.
    /// If the icon is already visible, this method has no effect.
    ///
    /// - Returns: true if the icon was successfully shown, false otherwise
    ///
    /// Note: On some platforms, showing a tray icon may fail if the
    /// system tray is not available or if there are too many icons.
    public func show() -> Bool {
        guard let cTrayIcon = cTrayIcon else { return false }
        return native_tray_icon_show(cTrayIcon)
    }

    /// Hide the tray icon from the system tray.
    ///
    /// Removes the tray icon from the system notification area without
    /// destroying the TrayIcon object. The icon can be shown again later
    /// using show().
    ///
    /// - Returns: true if the icon was successfully hidden, false otherwise
    public func hide() -> Bool {
        guard let cTrayIcon = cTrayIcon else { return false }
        return native_tray_icon_hide(cTrayIcon)
    }

    /// Programmatically display the context menu at a specified location.
    ///
    /// Shows the tray icon's context menu at the given screen coordinates.
    /// This allows for manually triggering the context menu through keyboard
    /// shortcuts, other UI events, or programmatic control.
    ///
    /// - Parameter position: The position in screen coordinates where to show the menu
    /// - Returns: true if the menu was successfully shown, false otherwise
    ///
    /// Note: If no context menu has been set via setContextMenu(), this method
    /// will return false. The coordinates are in screen/global coordinates,
    /// not relative to any window.
    ///
    /// Example:
    /// ```swift
    /// // Show context menu near the tray icon
    /// let bounds = trayIcon.bounds
    /// let position = Point(x: bounds.x, y: bounds.y + bounds.height)
    /// trayIcon.showContextMenu(at: position)
    /// ```
    public func showContextMenu(at position: Point) -> Bool {
        guard let cTrayIcon = cTrayIcon else { return false }
        return native_tray_icon_show_context_menu(cTrayIcon, position.x, position.y)
    }

    /// Display the context menu at the tray icon's location.
    ///
    /// Shows the context menu at a default position near the tray icon.
    /// This is a convenience method that automatically determines an appropriate
    /// position based on the tray icon's current location.
    ///
    /// - Returns: true if the menu was successfully shown, false otherwise
    ///
    /// Note: The exact positioning behavior may vary by platform:
    /// - macOS: Menu appears below the status item
    /// - Windows: Menu appears near the notification area
    /// - Linux: Menu appears at cursor position or near tray area
    ///
    /// Example:
    /// ```swift
    /// // Show context menu at default location
    /// trayIcon.showContextMenu()
    /// ```
    public func showContextMenu() -> Bool {
        guard let cTrayIcon = cTrayIcon else { return false }
        return native_tray_icon_show_context_menu_default(cTrayIcon)
    }

    /// Set the left click handler for this tray icon
    public func onLeftClick(_ handler: @escaping TrayIconClickHandler) {
        leftClickHandler = handler

        guard let cTrayIcon = cTrayIcon else { return }

        let userData = Unmanaged.passRetained(self).toOpaque()
        let listenerId = native_tray_icon_add_listener(cTrayIcon, NATIVE_TRAY_ICON_EVENT_CLICKED, { (event, userData) in
            guard let event = event, let userData = userData else { return }
            let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userData).takeUnretainedValue()

            let cEvent = event.withMemoryRebound(to: native_tray_icon_clicked_event_t.self, capacity: 1) { $0.pointee }
            let button = withUnsafeBytes(of: cEvent.button) { bytes in
                let data = Array(bytes)
                if let nullIndex = data.firstIndex(of: 0) {
                    return String(bytes: data[0..<nullIndex], encoding: .utf8) ?? ""
                } else {
                    return String(bytes: data, encoding: .utf8) ?? ""
                }
            }

            // Only handle left clicks
            if button == "left" {
                let swiftEvent = TrayIconClickedEvent(
                    trayIconId: Int(cEvent.tray_icon_id),
                    button: button
                )
                trayIcon.leftClickHandler?(swiftEvent)
            }
        }, userData)
        
        if listenerId >= 0 {
            listenerIds.append(Int(listenerId))
        }
    }

    /// Set the right click handler for this tray icon
    public func onRightClick(_ handler: @escaping TrayIconRightClickHandler) {
        rightClickHandler = handler

        guard let cTrayIcon = cTrayIcon else { return }

        let userData = Unmanaged.passRetained(self).toOpaque()
        let listenerId = native_tray_icon_add_listener(cTrayIcon, NATIVE_TRAY_ICON_EVENT_RIGHT_CLICKED, { (event, userData) in
            guard let event = event, let userData = userData else { return }
            let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userData).takeUnretainedValue()

            let cEvent = event.withMemoryRebound(to: native_tray_icon_right_clicked_event_t.self, capacity: 1) { $0.pointee }
            let swiftEvent = TrayIconRightClickedEvent(
                trayIconId: Int(cEvent.tray_icon_id)
            )
            trayIcon.rightClickHandler?(swiftEvent)
        }, userData)
        
        if listenerId >= 0 {
            listenerIds.append(Int(listenerId))
        }
    }

    /// Set the double click handler for this tray icon
    public func onDoubleClick(_ handler: @escaping TrayIconDoubleClickHandler) {
        doubleClickHandler = handler

        guard let cTrayIcon = cTrayIcon else { return }

        let userData = Unmanaged.passRetained(self).toOpaque()
        let listenerId = native_tray_icon_add_listener(cTrayIcon, NATIVE_TRAY_ICON_EVENT_DOUBLE_CLICKED, { (event, userData) in
            guard let event = event, let userData = userData else { return }
            let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userData).takeUnretainedValue()

            let cEvent = event.withMemoryRebound(to: native_tray_icon_double_clicked_event_t.self, capacity: 1) { $0.pointee }
            let swiftEvent = TrayIconDoubleClickedEvent(
                trayIconId: Int(cEvent.tray_icon_id)
            )
            trayIcon.doubleClickHandler?(swiftEvent)
        }, userData)
        
        if listenerId >= 0 {
            listenerIds.append(Int(listenerId))
        }
    }

    /// Internal method to handle left mouse click events.
    ///
    /// This method is called internally by platform-specific code
    /// when a left click event occurs on the tray icon.
    internal func handleLeftClick() {
        let event = TrayIconClickedEvent(trayIconId: id, button: "left")
        leftClickHandler?(event)
    }
    
    /// Internal method to handle right mouse click events.
    ///
    /// This method is called internally by platform-specific code
    /// when a right click event occurs on the tray icon.
    internal func handleRightClick() {
        let event = TrayIconRightClickedEvent(trayIconId: id)
        rightClickHandler?(event)
    }
    
    /// Internal method to handle double click events.
    ///
    /// This method is called internally by platform-specific code
    /// when a double click event occurs on the tray icon.
    internal func handleDoubleClick() {
        let event = TrayIconDoubleClickedEvent(trayIconId: id)
        doubleClickHandler?(event)
    }

    /// Get the native tray icon handle (for internal use)
    internal var nativeHandle: native_tray_icon_t? {
        return cTrayIcon
    }
}

