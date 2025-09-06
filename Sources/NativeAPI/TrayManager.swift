import CNativeAPI
import Foundation

/// Manages system tray icons
public class TrayManager: @unchecked Sendable {
    public static let shared = TrayManager()

    private init() {}

    /// Check if system tray is supported on the current platform
    /// - Returns: true if system tray is supported, false otherwise
    public var isSupported: Bool {
        return native_tray_manager_is_supported()
    }

    /// Create a new tray icon
    /// - Returns: A new TrayIcon instance, or nil if creation failed
    public func createTrayIcon() -> TrayIcon? {
        guard let handle = native_tray_manager_create() else {
            return nil
        }
        return TrayIcon(nativeHandle: handle)
    }

    /// Get a tray icon by its ID
    /// - Parameter id: The tray icon ID
    /// - Returns: TrayIcon instance, or nil if not found
    public func getTrayIcon(withId id: Int) -> TrayIcon? {
        guard let handle = native_tray_manager_get(native_tray_icon_id_t(id)) else {
            return nil
        }
        return TrayIcon(nativeHandle: handle)
    }

    /// Get all managed tray icons
    /// - Returns: Array of all tray icons
    public func getAllTrayIcons() -> [TrayIcon] {
        let trayIconList = native_tray_manager_get_all()
        defer { native_tray_icon_list_free(trayIconList) }

        var trayIcons: [TrayIcon] = []
        for i in 0..<trayIconList.count {
            if let handle = trayIconList.tray_icons.advanced(by: i).pointee {
                if let trayIcon = TrayIcon(nativeHandle: handle) {
                    trayIcons.append(trayIcon)
                }
            }
        }
        return trayIcons
    }

    /// Destroy a tray icon by its ID
    /// - Parameter id: The tray icon ID to destroy
    /// - Returns: true if tray icon was found and destroyed, false otherwise
    @discardableResult
    public func destroyTrayIcon(withId id: Int) -> Bool {
        return native_tray_manager_destroy(native_tray_icon_id_t(id))
    }

    /// Destroy a tray icon
    /// - Parameter trayIcon: The tray icon to destroy
    /// - Returns: true if tray icon was found and destroyed, false otherwise
    @discardableResult
    public func destroyTrayIcon(_ trayIcon: TrayIcon) -> Bool {
        return destroyTrayIcon(withId: trayIcon.id)
    }
}

// MARK: - Convenience Methods

extension TrayManager {
    /// Create and configure a tray icon in one step
    /// - Parameters:
    ///   - icon: Path to icon file or base64 encoded image data
    ///   - tooltip: The tooltip text (optional)
    ///   - title: The title text (optional)
    ///   - configure: Additional configuration closure (optional)
    /// - Returns: A new TrayIcon instance, or nil if creation failed
    public func createTrayIcon(
        icon: String,
        tooltip: String? = nil,
        title: String? = nil,
        configure: ((TrayIcon) -> Void)? = nil
    ) -> TrayIcon? {
        guard let trayIcon = createTrayIcon() else {
            return nil
        }

        trayIcon.setIcon(icon)
        if let tooltip = tooltip {
            trayIcon.setTooltip(tooltip)
        }
        if let title = title {
            trayIcon.setTitle(title)
        }

        configure?(trayIcon)
        return trayIcon
    }

    /// Create a tray icon with a context menu
    /// - Parameters:
    ///   - icon: Path to icon file or base64 encoded image data
    ///   - tooltip: The tooltip text (optional)
    ///   - menuBuilder: Closure to build the context menu
    /// - Returns: A new TrayIcon instance, or nil if creation failed
    public func createTrayIcon(
        icon: String,
        tooltip: String? = nil,
        menuBuilder: (Menu) -> Void
    ) -> TrayIcon? {
        guard let trayIcon = createTrayIcon() else {
            return nil
        }

        trayIcon.setIcon(icon)
        if let tooltip = tooltip {
            trayIcon.setTooltip(tooltip)
        }

        let menu = Menu()
        menuBuilder(menu)
        trayIcon.setContextMenu(menu)

        return trayIcon
    }

    /// Create a tray icon with a pre-built context menu
    /// - Parameters:
    ///   - icon: Path to icon file or base64 encoded image data
    ///   - tooltip: The tooltip text (optional)
    ///   - menu: An existing menu to attach
    /// - Returns: A new TrayIcon instance, or nil if creation failed
    public func createTrayIcon(
        icon: String,
        tooltip: String? = nil,
        menu: Menu
    ) -> TrayIcon? {
        guard let trayIcon = createTrayIcon() else {
            return nil
        }

        trayIcon.setIcon(icon)
        if let tooltip = tooltip {
            trayIcon.setTooltip(tooltip)
        }

        trayIcon.setContextMenu(menu)
        return trayIcon
    }

    /// Get the number of currently managed tray icons
    public var trayIconCount: Int {
        return getAllTrayIcons().count
    }

    /// Check if there are any managed tray icons
    public var hasActiveTrayIcons: Bool {
        return trayIconCount > 0
    }

    /// Destroy all managed tray icons
    /// - Returns: Number of tray icons that were destroyed
    @discardableResult
    public func destroyAllTrayIcons() -> Int {
        let trayIcons = getAllTrayIcons()
        var destroyedCount = 0

        for trayIcon in trayIcons {
            if destroyTrayIcon(trayIcon) {
                destroyedCount += 1
            }
        }

        return destroyedCount
    }
}

// MARK: - Static Convenience Methods

extension TrayManager {
    /// Quick check if system tray is available
    /// - Returns: true if system tray is supported, false otherwise
    public static var isSystemTraySupported: Bool {
        return TrayManager.shared.isSupported
    }

    /// Quick access to create a tray icon
    /// - Returns: A new TrayIcon instance, or nil if creation failed
    public static func createTrayIcon() -> TrayIcon? {
        return TrayManager.shared.createTrayIcon()
    }

    /// Quick access to create and configure a tray icon
    /// - Parameters:
    ///   - icon: Path to icon file or base64 encoded image data
    ///   - tooltip: The tooltip text (optional)
    ///   - configure: Configuration closure (optional)
    /// - Returns: A new TrayIcon instance, or nil if creation failed
    public static func createTrayIcon(
        icon: String,
        tooltip: String? = nil,
        configure: ((TrayIcon) -> Void)? = nil
    ) -> TrayIcon? {
        return TrayManager.shared.createTrayIcon(
            icon: icon,
            tooltip: tooltip,
            configure: configure
        )
    }
}
