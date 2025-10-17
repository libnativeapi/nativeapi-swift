import CNativeAPI
import Foundation

/**
 * TrayManager is a singleton class that manages all system tray icons.
 *
 * This class provides a centralized way to create, manage, and destroy system
 * tray icons. It ensures that there's only one instance of the tray manager
 * throughout the application lifetime and provides thread-safe operations for
 * managing tray icons.
 *
 * - Note: This class is implemented as a singleton to ensure consistent
 * management of system tray resources across the entire application.
 */
public class TrayManager: @unchecked Sendable {
    /**
     * Get the singleton instance of TrayManager.
     *
     * This property provides access to the unique instance of TrayManager.
     * The instance is created on first call and remains alive for the
     * duration of the application.
     *
     * - Returns: The singleton TrayManager instance
     * - Note: This property is thread-safe
     */
    public static let shared = TrayManager()

    private init() {}

    /**
     * Check if the system tray is supported on the current platform.
     *
     * Some platforms or desktop environments may not support system tray
     * functionality. This method allows checking for availability before
     * attempting to create tray icons.
     *
     * - Returns: true if system tray is supported, false otherwise
     */
    public var isSupported: Bool {
        return native_tray_manager_is_supported()
    }

    /**
     * Get a tray icon by its unique ID.
     *
     * Retrieves a previously created tray icon using its assigned ID.
     *
     * - Parameter id: The unique identifier of the tray icon
     * - Returns: TrayIcon instance, or nil if not found
     */
    public func get(id: Int) -> TrayIcon? {
        guard let handle = native_tray_manager_get(native_tray_icon_id_t(id)) else {
            return nil
        }
        return TrayIcon(nativeHandle: handle)
    }

    /**
     * Get all managed tray icons.
     *
     * Returns an array containing all currently active tray icons
     * managed by this TrayManager instance.
     *
     * - Returns: Array of all active TrayIcon instances
     */
    public func getAll() -> [TrayIcon] {
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
}