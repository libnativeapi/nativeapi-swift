import CNativeAPI
import Foundation

/// Window event types
public enum WindowEventType {
    case created
    case closed
    case focused
    case blurred
    case minimized
    case maximized
    case restored
    case moved(Point)
    case resized(Size)

    internal init(_ cEventType: native_window_event_type_t, _ cEvent: native_window_event_t) {
        switch cEventType {
        case NATIVE_WINDOW_EVENT_CREATED:
            self = .created
        case NATIVE_WINDOW_EVENT_CLOSED:
            self = .closed
        case NATIVE_WINDOW_EVENT_FOCUSED:
            self = .focused
        case NATIVE_WINDOW_EVENT_BLURRED:
            self = .blurred
        case NATIVE_WINDOW_EVENT_MINIMIZED:
            self = .minimized
        case NATIVE_WINDOW_EVENT_MAXIMIZED:
            self = .maximized
        case NATIVE_WINDOW_EVENT_RESTORED:
            self = .restored
        case NATIVE_WINDOW_EVENT_MOVED:
            self = .moved(Point(cEvent.data.moved.position))
        case NATIVE_WINDOW_EVENT_RESIZED:
            self = .resized(Size(cEvent.data.resized.size))
        default:
            self = .created
        }
    }
}

/// Window event data
public struct WindowEvent {
    public let type: WindowEventType
    public let windowId: Int

    internal init(_ cEvent: native_window_event_t) {
        self.type = WindowEventType(cEvent.type, cEvent)
        self.windowId = Int(cEvent.window_id)
    }
}

/// Window event callback closure
public typealias WindowEventCallback = (WindowEvent) -> Void

public class WindowManager: @unchecked Sendable {
    public static let shared = WindowManager()

    private var eventCallbacks: [Int: WindowEventCallback] = [:]
    private var callbackCounter = 0
    private let callbackQueue = DispatchQueue(label: "com.nativeapi.windowmanager.callbacks")

    private init() {}

    /// Create a new window with the specified options
    public func create(with options: WindowOptions) -> Window? {
        guard let handle = native_window_manager_create(options.cOptions) else {
            return nil
        }
        return Window(handle: handle)
    }

    /// Create a new window with default options
    public func create() -> Window? {
        let options = WindowOptions()
        return create(with: options)
    }

    /// Get a list of all windows
    public func getAll() -> WindowList {
        let cList = native_window_manager_get_all()
        return WindowList(cList)
    }

    /// Find a window by its ID
    public func get(by id: Int) -> Window? {
        guard let handle = native_window_manager_get(native_window_id_t(id)) else {
            return nil
        }
        return Window(handle: handle)
    }

    /// Get the currently focused window
    public func getCurrent() -> Window? {
        guard let handle = native_window_manager_get_current() else {
            return nil
        }
        return Window(handle: handle)
    }

    /// Destroy a window by its ID
    public func destroy(id: Int) -> Bool {
        return native_window_manager_destroy(native_window_id_t(id))
    }

    /// Shutdown the window manager
    public func shutdown() {
        native_window_manager_shutdown()
    }

    // MARK: - Event Handling

    /// Register a callback for window events
    @discardableResult
    public func registerEventCallback(_ callback: @escaping WindowEventCallback) -> Int {
        return callbackQueue.sync {
            callbackCounter += 1
            let callbackId = callbackCounter
            eventCallbacks[callbackId] = callback

            let cCallbackId = native_window_manager_register_event_callback(
                { cEventPtr, userData in
                    guard let cEventPtr = cEventPtr else { return }
                    let cEvent = cEventPtr.pointee
                    let event = WindowEvent(cEvent)

                    // Get the callback ID from user data
                    let callbackId = Int(bitPattern: userData)

                    // Execute callback on main queue
                    DispatchQueue.main.async {
                        WindowManager.shared.eventCallbacks[callbackId]?(event)
                    }
                }, UnsafeMutableRawPointer(bitPattern: callbackId))

            // If C registration failed, remove from our dictionary
            if cCallbackId == -1 {
                eventCallbacks.removeValue(forKey: callbackId)
                return -1
            }

            return callbackId
        }
    }

    /// Unregister a window event callback
    @discardableResult
    public func unregisterEventCallback(_ callbackId: Int) -> Bool {
        return callbackQueue.sync {
            guard eventCallbacks[callbackId] != nil else {
                return false
            }

            let success = native_window_manager_unregister_event_callback(Int32(callbackId))
            if success {
                eventCallbacks.removeValue(forKey: callbackId)
            }

            return success
        }
    }
}
