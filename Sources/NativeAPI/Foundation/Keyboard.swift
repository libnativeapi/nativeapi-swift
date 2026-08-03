// AUTO-GENERATED. DO NOT EDIT.
// Any manual changes WILL BE LOST when this file is regenerated.

import CNativeAPI
import Foundation

public enum ModifierKey: CInt {
  case none = 0
  case shift = 1
  case ctrl = 2
  case alt = 4
  case meta = 8
  case fn = 16
  case capsLock = 32
  case numLock = 64
  case scrollLock = 128

  init(raw: native_modifier_key_t) {
    switch raw {
    case NATIVE_MODIFIER_KEY_NONE: self = .none
    case NATIVE_MODIFIER_KEY_SHIFT: self = .shift
    case NATIVE_MODIFIER_KEY_CTRL: self = .ctrl
    case NATIVE_MODIFIER_KEY_ALT: self = .alt
    case NATIVE_MODIFIER_KEY_META: self = .meta
    case NATIVE_MODIFIER_KEY_FN: self = .fn
    case NATIVE_MODIFIER_KEY_CAPS_LOCK: self = .capsLock
    case NATIVE_MODIFIER_KEY_NUM_LOCK: self = .numLock
    case NATIVE_MODIFIER_KEY_SCROLL_LOCK: self = .scrollLock
    default: self = .none
    }
  }

  var raw: native_modifier_key_t {
    native_modifier_key_t(rawValue: UInt32(self.rawValue))
  }
}

public struct KeyboardAccelerator {
  public var modifiers: ModifierKey
  public var key: String?

  public init(modifiers: ModifierKey, key: String?) {
    self.modifiers = modifiers
    self.key = key
  }
}

extension KeyboardAccelerator {
  init(raw: native_keyboard_accelerator_t) {
    self.init(modifiers: ModifierKey(raw: raw.modifiers), key: raw.key.map { String(cString: $0) })
  }

  func toRaw() -> native_keyboard_accelerator_t {
    var raw = native_keyboard_accelerator_t()
    raw.modifiers = self.modifiers.raw
    raw.key = self.key.map { strdup($0) } ?? nil
    return raw
  }

  static func releaseRaw(_ raw: inout native_keyboard_accelerator_t) {
    free(raw.key)
    raw.key = nil
  }
}

/// One `KeyboardEvent`, in its concrete form.
public enum KeyboardEvent {
  case keyPressed(keycode: CInt)
  case keyReleased(keycode: CInt)
  case modifierKeysChanged(keycode: CInt, modifierKeys: UInt32)

  init?(raw: native_keyboard_event_t) {
    switch raw.type {
    case NATIVE_KEYBOARD_EVENT_TYPE_KEY_PRESSED: self = .keyPressed(keycode: raw.keycode)
    case NATIVE_KEYBOARD_EVENT_TYPE_KEY_RELEASED: self = .keyReleased(keycode: raw.keycode)
    case NATIVE_KEYBOARD_EVENT_TYPE_MODIFIER_KEYS_CHANGED: self = .modifierKeysChanged(keycode: raw.keycode, modifierKeys: raw.data.modifier_keys_changed.modifier_keys)
    default: return nil
    }
  }
}

