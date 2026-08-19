// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public final class TrayManager: Sendable {
  /// The shared instance backed by the native singleton.
  public static let shared = TrayManager()

  private init() {}

  public func isSupported() -> Bool {
    return native_tray_manager_is_supported()
  }

  public func get(id: TrayIconId) -> TrayIcon? {
    let handle = native_tray_manager_get(id)
    guard handle != NATIVE_INVALID_TRAY_ICON else { return nil }
    return TrayIcon(nativeHandle: handle)
  }

  public func getAll() -> [TrayIcon] {
    var list = native_tray_manager_get_all()
    var items: [TrayIcon] = []
    if let buffer = list.tray_icons {
      for index in 0..<Int(list.count) {
        items.append(TrayIcon(nativeHandle: buffer[index]))
      }
    }
    // The handles now belong to `items`; free just the array.
    native_tray_icon_list_release(&list)
    return items
  }

}

