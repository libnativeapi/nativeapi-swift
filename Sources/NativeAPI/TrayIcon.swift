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

/// Represents a system tray icon
public class TrayIcon {
    private var cTrayIcon: native_tray_icon_t?
    private var leftClickHandler: TrayIconClickHandler?
    private var rightClickHandler: TrayIconRightClickHandler?
    private var doubleClickHandler: TrayIconDoubleClickHandler?
    private var contextMenu: Menu?

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
    public var bounds: Rectangle? {
        guard let cTrayIcon = cTrayIcon else { return nil }
        var cRect = native_rectangle_t()
        if native_tray_icon_get_bounds(cTrayIcon, &cRect) {
            return Rectangle(x: cRect.x, y: cRect.y, width: cRect.width, height: cRect.height)
        }
        return nil
    }

    /// Initialize a new tray icon
    public init() {
        cTrayIcon = native_tray_icon_create()
    }

    /// Initialize a tray icon from an existing native handle
    internal init?(nativeHandle: native_tray_icon_t?) {
        guard let nativeHandle = nativeHandle else { return nil }
        cTrayIcon = nativeHandle
    }

    deinit {
        if let cTrayIcon = cTrayIcon {
            native_tray_icon_destroy(cTrayIcon)
        }
    }

    /// Set the icon image for this tray icon
    public func setIcon(_ icon: String) {
        guard let cTrayIcon = cTrayIcon else { return }
        native_tray_icon_set_icon(cTrayIcon, icon)
    }

    /// Set the title text for this tray icon
    public func setTitle(_ title: String) {
        self.title = title
    }

    /// Set the tooltip text for this tray icon
    public func setTooltip(_ tooltip: String) {
        self.tooltip = tooltip
    }

    /// Set the context menu for this tray icon
    public func setContextMenu(_ menu: Menu) {
        guard let cTrayIcon = cTrayIcon, let cMenu = menu.nativeHandle else { return }
        native_tray_icon_set_context_menu(cTrayIcon, cMenu)
        contextMenu = menu
    }

    /// Show this tray icon in the system tray
    public func show() -> Bool {
        guard let cTrayIcon = cTrayIcon else { return false }
        return native_tray_icon_show(cTrayIcon)
    }

    /// Hide this tray icon from the system tray
    public func hide() -> Bool {
        guard let cTrayIcon = cTrayIcon else { return false }
        return native_tray_icon_hide(cTrayIcon)
    }

    /// Show the context menu at the specified position
    public func showContextMenu(at position: Point) -> Bool {
        guard let cTrayIcon = cTrayIcon else { return false }
        return native_tray_icon_show_context_menu(cTrayIcon, position.x, position.y)
    }

    /// Show the context menu at the default position
    public func showContextMenu() -> Bool {
        guard let cTrayIcon = cTrayIcon else { return false }
        return native_tray_icon_show_context_menu_default(cTrayIcon)
    }

    /// Set the left click handler for this tray icon
    public func onLeftClick(_ handler: @escaping TrayIconClickHandler) {
        leftClickHandler = handler

        guard let cTrayIcon = cTrayIcon else { return }

        let userData = Unmanaged.passRetained(self).toOpaque()
        _ = native_tray_icon_add_listener(cTrayIcon, NATIVE_TRAY_ICON_EVENT_CLICKED, { (event, userData) in
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
    }

    /// Set the right click handler for this tray icon
    public func onRightClick(_ handler: @escaping TrayIconRightClickHandler) {
        rightClickHandler = handler

        guard let cTrayIcon = cTrayIcon else { return }

        let userData = Unmanaged.passRetained(self).toOpaque()
        _ = native_tray_icon_add_listener(cTrayIcon, NATIVE_TRAY_ICON_EVENT_RIGHT_CLICKED, { (event, userData) in
            guard let event = event, let userData = userData else { return }
            let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userData).takeUnretainedValue()

            let cEvent = event.withMemoryRebound(to: native_tray_icon_right_clicked_event_t.self, capacity: 1) { $0.pointee }
            let swiftEvent = TrayIconRightClickedEvent(
                trayIconId: Int(cEvent.tray_icon_id)
            )
            trayIcon.rightClickHandler?(swiftEvent)
        }, userData)
    }

    /// Set the double click handler for this tray icon
    public func onDoubleClick(_ handler: @escaping TrayIconDoubleClickHandler) {
        doubleClickHandler = handler

        guard let cTrayIcon = cTrayIcon else { return }

        let userData = Unmanaged.passRetained(self).toOpaque()
        _ = native_tray_icon_add_listener(cTrayIcon, NATIVE_TRAY_ICON_EVENT_DOUBLE_CLICKED, { (event, userData) in
            guard let event = event, let userData = userData else { return }
            let trayIcon = Unmanaged<TrayIcon>.fromOpaque(userData).takeUnretainedValue()

            let cEvent = event.withMemoryRebound(to: native_tray_icon_double_clicked_event_t.self, capacity: 1) { $0.pointee }
            let swiftEvent = TrayIconDoubleClickedEvent(
                trayIconId: Int(cEvent.tray_icon_id)
            )
            trayIcon.doubleClickHandler?(swiftEvent)
        }, userData)
    }

    /// Get the native tray icon handle (for internal use)
    internal var nativeHandle: native_tray_icon_t? {
        return cTrayIcon
    }
}

