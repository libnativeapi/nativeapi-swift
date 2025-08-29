import CNativeAPI
import Foundation

/// Represents a system tray icon
public class TrayIcon: @unchecked Sendable {
    internal let handle: native_tray_icon_t
    private var leftClickCallback: (() -> Void)?
    private var rightClickCallback: (() -> Void)?
    private var doubleClickCallback: (() -> Void)?

    /// Unique identifier for this tray icon
    public var id: Int {
        return Int(native_tray_icon_get_id(handle))
    }

    /// Create a new tray icon
    public init() {
        guard let handle = native_tray_icon_create() else {
            fatalError("Failed to create tray icon")
        }
        self.handle = handle
        setupCallbacks()
    }

    /// Create a tray icon from a native handle
    internal init(handle: native_tray_icon_t) {
        self.handle = handle
        setupCallbacks()
    }

    /// Create a tray icon from a native platform object
    public init(nativeTray: UnsafeMutableRawPointer) {
        guard let handle = native_tray_icon_create_from_native(nativeTray) else {
            fatalError("Failed to create tray icon from native object")
        }
        self.handle = handle
        setupCallbacks()
    }

    deinit {
        native_tray_icon_destroy(handle)
    }

    private func setupCallbacks() {
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        // Set up left click callback
        native_tray_icon_set_on_left_click(
            handle,
            { userData in
                guard let userData = userData else { return }
                let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    trayIcon.leftClickCallback?()
                }
            }, selfPtr)

        // Set up right click callback
        native_tray_icon_set_on_right_click(
            handle,
            { userData in
                guard let userData = userData else { return }
                let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    trayIcon.rightClickCallback?()
                }
            }, selfPtr)

        // Set up double click callback
        native_tray_icon_set_on_double_click(
            handle,
            { userData in
                guard let userData = userData else { return }
                let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async {
                    trayIcon.doubleClickCallback?()
                }
            }, selfPtr)
    }

    /// Set the icon image for the tray icon
    /// - Parameter icon: Path to icon file or base64 encoded image data
    public func setIcon(_ icon: String) {
        native_tray_icon_set_icon(handle, icon)
    }

    /// Set the title text for the tray icon
    /// - Parameter title: The title text to set
    public func setTitle(_ title: String) {
        native_tray_icon_set_title(handle, title)
    }

    /// Get the title text of the tray icon
    public var title: String {
        let bufferSize = 256
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        let length = native_tray_icon_get_title(handle, buffer, bufferSize)
        if length >= 0 {
            return String(cString: buffer)
        }
        return ""
    }

    /// Set the tooltip text for the tray icon
    /// - Parameter tooltip: The tooltip text to set
    public func setTooltip(_ tooltip: String) {
        native_tray_icon_set_tooltip(handle, tooltip)
    }

    /// Get the tooltip text of the tray icon
    public var tooltip: String {
        let bufferSize = 256
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        let length = native_tray_icon_get_tooltip(handle, buffer, bufferSize)
        if length >= 0 {
            return String(cString: buffer)
        }
        return ""
    }

    /// Set the context menu for the tray icon
    /// - Parameter menu: The context menu to set
    public func setContextMenu(_ menu: Menu) {
        native_tray_icon_set_context_menu(handle, menu.handle)
    }

    /// Get the context menu of the tray icon
    public var contextMenu: Menu? {
        guard let menuHandle = native_tray_icon_get_context_menu(handle) else {
            return nil
        }
        return Menu(handle: menuHandle)
    }

    /// Remove the context menu from the tray icon
    public func removeContextMenu() {
        native_tray_icon_set_context_menu(handle, nil)
    }

    /// Get the screen bounds of the tray icon
    public var bounds: Rectangle? {
        var cBounds = native_rectangle_t()
        if native_tray_icon_get_bounds(handle, &cBounds) {
            return Rectangle(cBounds)
        }
        return nil
    }

    /// Show the tray icon in the system tray
    /// - Returns: true if shown successfully, false otherwise
    @discardableResult
    public func show() -> Bool {
        return native_tray_icon_show(handle)
    }

    /// Hide the tray icon from the system tray
    /// - Returns: true if hidden successfully, false otherwise
    @discardableResult
    public func hide() -> Bool {
        return native_tray_icon_hide(handle)
    }

    /// Check if the tray icon is currently visible
    public var isVisible: Bool {
        return native_tray_icon_is_visible(handle)
    }

    /// Set callback for left mouse click events
    /// - Parameter callback: The callback function to execute on left click
    public func onLeftClick(_ callback: @escaping () -> Void) {
        self.leftClickCallback = callback
    }

    /// Set callback for right mouse click events
    /// - Parameter callback: The callback function to execute on right click
    public func onRightClick(_ callback: @escaping () -> Void) {
        self.rightClickCallback = callback
    }

    /// Set callback for double click events
    /// - Parameter callback: The callback function to execute on double click
    public func onDoubleClick(_ callback: @escaping () -> Void) {
        self.doubleClickCallback = callback
    }

    /// Show the context menu at specified coordinates
    /// - Parameters:
    ///   - x: The x-coordinate in screen coordinates
    ///   - y: The y-coordinate in screen coordinates
    /// - Returns: true if menu was shown successfully, false otherwise
    @discardableResult
    public func showContextMenu(at x: Double, y: Double) -> Bool {
        return native_tray_icon_show_context_menu(handle, x, y)
    }

    /// Show the context menu at specified point
    /// - Parameter point: The point in screen coordinates
    /// - Returns: true if menu was shown successfully, false otherwise
    @discardableResult
    public func showContextMenu(at point: Point) -> Bool {
        return native_tray_icon_show_context_menu(handle, point.x, point.y)
    }

    /// Show the context menu at default location
    /// - Returns: true if menu was shown successfully, false otherwise
    @discardableResult
    public func showContextMenuDefault() -> Bool {
        return native_tray_icon_show_context_menu_default(handle)
    }
}

// MARK: - Convenience Extensions

extension TrayIcon {
    /// Create a tray icon with basic configuration
    /// - Parameters:
    ///   - icon: Path to icon file or base64 encoded image data
    ///   - tooltip: The tooltip text (optional)
    ///   - title: The title text (optional)
    public convenience init(icon: String, tooltip: String? = nil, title: String? = nil) {
        self.init()
        setIcon(icon)
        if let tooltip = tooltip {
            setTooltip(tooltip)
        }
        if let title = title {
            setTitle(title)
        }
    }

    /// Create a tray icon with context menu
    /// - Parameters:
    ///   - icon: Path to icon file or base64 encoded image data
    ///   - tooltip: The tooltip text (optional)
    ///   - menu: The context menu to set
    public convenience init(icon: String, tooltip: String? = nil, menu: Menu) {
        self.init(icon: icon, tooltip: tooltip)
        setContextMenu(menu)
    }

    /// Configure the tray icon with a builder pattern
    /// - Parameter configure: Configuration closure
    /// - Returns: Self for chaining
    @discardableResult
    public func configure(_ configure: (TrayIcon) -> Void) -> TrayIcon {
        configure(self)
        return self
    }
}
