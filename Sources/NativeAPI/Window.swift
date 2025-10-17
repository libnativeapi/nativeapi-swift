import CNativeAPI
import Foundation

// Geometry types are now defined in Foundation/Geometry.swift

/// Window options for creating new windows
public class WindowOptions {
    internal let cOptions: UnsafeMutablePointer<native_window_options_t>

    public init() {
        cOptions = native_window_options_create()!
    }

    deinit {
        native_window_options_destroy(cOptions)
    }

    /// Set the window title
    public func setTitle(_ title: String) -> Bool {
        return native_window_options_set_title(cOptions, title)
    }

    /// Set the initial window size
    public func setSize(_ size: Size) {
        native_window_options_set_size(cOptions, size.width, size.height)
    }

    /// Set the minimum window size
    public func setMinimumSize(_ size: Size) {
        native_window_options_set_minimum_size(cOptions, size.width, size.height)
    }

    /// Set the maximum window size
    public func setMaximumSize(_ size: Size) {
        native_window_options_set_maximum_size(cOptions, size.width, size.height)
    }

    /// Set whether the window should be centered on screen
    public func setCentered(_ centered: Bool) {
        native_window_options_set_centered(cOptions, centered)
    }
}

/// Represents a native window
public class Window {
    internal let handle: native_window_t

    internal init(handle: native_window_t) {
        self.handle = handle
    }

    // MARK: - Basic Properties

    /// Get the unique window ID
    public var id: Int {
        return Int(native_window_get_id(handle))
    }

    /// Get or set the window title
    public var title: String {
        get {
            guard let cTitle = native_window_get_title(handle) else {
                return ""
            }
            let title = String(cString: cTitle)
            native_window_free_string(cTitle)
            return title
        }
        set {
            _ = native_window_set_title(handle, newValue)
        }
    }

    /// Get or set the window opacity (0.0 to 1.0)
    public var opacity: Float {
        get { return native_window_get_opacity(handle) }
        set { native_window_set_opacity(handle, newValue) }
    }

    // MARK: - Focus Management

    /// Focus the window
    public func focus() {
        native_window_focus(handle)
    }

    /// Remove focus from the window
    public func blur() {
        native_window_blur(handle)
    }

    /// Check if the window is currently focused
    public var isFocused: Bool {
        return native_window_is_focused(handle)
    }

    /// Get or set whether the window can be focused
    public var isFocusable: Bool {
        get { return native_window_is_focusable(handle) }
        set { native_window_set_focusable(handle, newValue) }
    }

    // MARK: - Visibility

    /// Show the window
    public func show() {
        native_window_show(handle)
    }

    /// Show the window without activating it
    public func showInactive() {
        native_window_show_inactive(handle)
    }

    /// Hide the window
    public func hide() {
        native_window_hide(handle)
    }

    /// Check if the window is currently visible
    public var isVisible: Bool {
        return native_window_is_visible(handle)
    }

    // MARK: - Window State

    /// Maximize the window
    public func maximize() {
        native_window_maximize(handle)
    }

    /// Restore the window from maximized state
    public func unmaximize() {
        native_window_unmaximize(handle)
    }

    /// Check if the window is currently maximized
    public var isMaximized: Bool {
        return native_window_is_maximized(handle)
    }

    /// Minimize the window
    public func minimize() {
        native_window_minimize(handle)
    }

    /// Restore the window from minimized state
    public func restore() {
        native_window_restore(handle)
    }

    /// Check if the window is currently minimized
    public var isMinimized: Bool {
        return native_window_is_minimized(handle)
    }

    /// Get or set fullscreen state
    public var isFullscreen: Bool {
        get { return native_window_is_fullscreen(handle) }
        set { native_window_set_fullscreen(handle, newValue) }
    }

    // MARK: - Geometry

    /// Get or set the window bounds (position and size)
    public var bounds: Rect {
        get { return Rect(native_window_get_bounds(handle)) }
        set { native_window_set_bounds(handle, newValue.cStruct) }
    }

    /// Get or set the window size
    public var size: Size {
        get { return Size(native_window_get_size(handle)) }
        set { setSize(newValue, animate: false) }
    }

    /// Set the window size with optional animation
    public func setSize(_ size: Size, animate: Bool) {
        native_window_set_size(handle, size.width, size.height, animate)
    }

    /// Get or set the content size (excluding window decorations)
    public var contentSize: Size {
        get { return Size(native_window_get_content_size(handle)) }
        set { native_window_set_content_size(handle, newValue.width, newValue.height) }
    }

    /// Get or set the minimum window size
    public var minimumSize: Size {
        get { return Size(native_window_get_minimum_size(handle)) }
        set { native_window_set_minimum_size(handle, newValue.width, newValue.height) }
    }

    /// Get or set the maximum window size
    public var maximumSize: Size {
        get { return Size(native_window_get_maximum_size(handle)) }
        set { native_window_set_maximum_size(handle, newValue.width, newValue.height) }
    }

    /// Get or set the window position
    public var position: Point {
        get { return Point(native_window_get_position(handle)) }
        set { native_window_set_position(handle, newValue.x, newValue.y) }
    }

    // MARK: - Window Properties

    /// Get or set whether the window is resizable
    public var isResizable: Bool {
        get { return native_window_is_resizable(handle) }
        set { native_window_set_resizable(handle, newValue) }
    }

    /// Get or set whether the window is movable
    public var isMovable: Bool {
        get { return native_window_is_movable(handle) }
        set { native_window_set_movable(handle, newValue) }
    }

    /// Get or set whether the window can be minimized
    public var isMinimizable: Bool {
        get { return native_window_is_minimizable(handle) }
        set { native_window_set_minimizable(handle, newValue) }
    }

    /// Get or set whether the window can be maximized
    public var isMaximizable: Bool {
        get { return native_window_is_maximizable(handle) }
        set { native_window_set_maximizable(handle, newValue) }
    }

    /// Get or set whether the window can be put in fullscreen mode
    public var isFullscreenable: Bool {
        get { return native_window_is_fullscreenable(handle) }
        set { native_window_set_fullscreenable(handle, newValue) }
    }

    /// Get or set whether the window can be closed
    public var isClosable: Bool {
        get { return native_window_is_closable(handle) }
        set { native_window_set_closable(handle, newValue) }
    }

    /// Get or set whether the window stays on top of other windows
    public var isAlwaysOnTop: Bool {
        get { return native_window_is_always_on_top(handle) }
        set { native_window_set_always_on_top(handle, newValue) }
    }

    /// Get or set whether the window has a shadow
    public var hasShadow: Bool {
        get { return native_window_has_shadow(handle) }
        set { native_window_set_has_shadow(handle, newValue) }
    }

    /// Get or set whether the window is visible on all workspaces
    public var isVisibleOnAllWorkspaces: Bool {
        get { return native_window_is_visible_on_all_workspaces(handle) }
        set { native_window_set_visible_on_all_workspaces(handle, newValue) }
    }

    /// Get or set whether the window ignores mouse events
    public var ignoreMouseEvents: Bool {
        get { return native_window_is_ignore_mouse_events(handle) }
        set { native_window_set_ignore_mouse_events(handle, newValue) }
    }

    // MARK: - Window Interactions

    /// Start dragging the window
    public func startDragging() {
        native_window_start_dragging(handle)
    }

    /// Start resizing the window
    public func startResizing() {
        native_window_start_resizing(handle)
    }

    // MARK: - Platform-specific

    /// Get the native object handle
    public var nativeObject: UnsafeMutableRawPointer? {
        return native_window_get_native_object(handle)
    }
}

/// Window list container
public struct WindowList {
    private let cList: native_window_list_t
    private let shouldFree: Bool

    internal init(_ cList: native_window_list_t, shouldFree: Bool = true) {
        self.cList = cList
        self.shouldFree = shouldFree
    }

    /// Get all windows in the list
    public var windows: [Window] {
        let count = Int(cList.count)
        guard count > 0, let windowsPtr = cList.windows else {
            return []
        }

        var result: [Window] = []
        for i in 0..<count {
            let handle = windowsPtr[i]
            if let handle = handle {
                result.append(Window(handle: handle))
            }
        }
        return result
    }

    /// Number of windows in the list
    public var count: Int {
        return Int(cList.count)
    }
}
