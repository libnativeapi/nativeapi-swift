import CNativeAPI
import Foundation

/// Display orientation enumeration
public enum DisplayOrientation: Int, CaseIterable {
    case portrait = 0
    case landscape = 90
    case portraitFlipped = 180
    case landscapeFlipped = 270
    
    public init(value: Int) {
        switch value {
        case 0: self = .portrait
        case 90: self = .landscape
        case 180: self = .portraitFlipped
        case 270: self = .landscapeFlipped
        default: self = .portrait
        }
    }
}

/// Display represents a single display/monitor
public class Display: BaseNativeHandleWrapper<native_display_t> {
    
    public init(nativeHandle: native_display_t) {
        super.init(nativeHandle: nativeHandle) { native_display_free($0) }
    }

    /// Unique identifier for this display
    public var id: String {
        guard let idPtr = native_display_get_id(nativeHandle) else {
            return ""
        }
        let id = String(cString: idPtr)
        free_c_str(idPtr)
        return id
    }

    /// Human-readable name of this display
    public var name: String {
        guard let namePtr = native_display_get_name(nativeHandle) else {
            return ""
        }
        let name = String(cString: namePtr)
        free_c_str(namePtr)
        return name
    }

    /// Position of this display in the virtual desktop
    public var position: Point {
        let nativePoint = native_display_get_position(nativeHandle)
        return Point(nativePoint)
    }

    /// Physical size of this display in pixels
    public var size: Size {
        let nativeSize = native_display_get_size(nativeHandle)
        return Size(nativeSize)
    }

    /// Work area of this display (excluding taskbar/dock)
    public var workArea: Rect {
        let nativeRect = native_display_get_work_area(nativeHandle)
        return Rect(nativeRect)
    }

    /// Scale factor of this display
    public var scaleFactor: Double {
        return native_display_get_scale_factor(nativeHandle)
    }

    /// Whether this is the primary display
    public var isPrimary: Bool {
        return native_display_is_primary(nativeHandle)
    }

    /// Orientation of this display
    public var orientation: DisplayOrientation {
        let nativeOrientation = native_display_get_orientation(nativeHandle)
        return DisplayOrientation(value: Int(nativeOrientation.rawValue))
    }

    /// Refresh rate of this display in Hz
    public var refreshRate: Int {
        return Int(native_display_get_refresh_rate(nativeHandle))
    }

    /// Bit depth of this display
    public var bitDepth: Int {
        return Int(native_display_get_bit_depth(nativeHandle))
    }

    /// Native platform-specific object handle
    public var nativeObject: UnsafeMutableRawPointer? {
        return native_display_get_native_object(nativeHandle)
    }
}
