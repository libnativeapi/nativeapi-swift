// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public enum AccessibilityManager {
  public static func enable() -> Void {
    native_accessibility_manager_enable()
  }

  public static func isEnabled() -> Bool {
    return native_accessibility_manager_is_enabled()
  }

}

