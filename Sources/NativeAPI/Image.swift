import Foundation
import CNativeAPI

/// A cross-platform image class for handling images across different platforms.
///
/// This class provides a unified interface for working with images and supports
/// multiple initialization methods including file paths and base64-encoded data.
///
/// Features:
/// - Load images from file paths
/// - Load images from base64-encoded strings
/// - Automatic format detection and conversion
/// - Memory-efficient internal representation
///
/// All Image instances must be created using static factory methods
/// (fromFile, fromBase64).
///
/// Example:
/// ```swift
/// // Create image from file path
/// let image1 = Image.fromFile("/path/to/icon.png")
///
/// // Create image from base64 string
/// let image2 = Image.fromBase64("data:image/png;base64,iVBORw0KGgo...")
///
/// // Use with TrayIcon
/// trayIcon.icon = image1
///
/// // Use with MenuItem
/// menuItem.icon = image2
///
/// // Get image dimensions
/// let size = image1.size
/// if size.width > 0 && size.height > 0 {
///   print("Image size: \(size.width)x\(size.height)")
/// }
///
/// // Get image format for debugging
/// let format = image1.format
/// print("Image format: \(format ?? "unknown")")
/// ```
public class Image: BaseNativeHandleWrapper<native_image_t> {
    
    /// Create an image from a file path.
    ///
    /// Loads an image from the specified file path on disk. The image format
    /// is automatically detected based on the file contents.
    ///
    /// Returns nil if loading failed.
    ///
    /// Supported formats depend on the platform:
    /// - macOS: PNG, JPEG, GIF, TIFF, BMP, ICO, PDF
    /// - Windows: PNG, JPEG, BMP, GIF, TIFF, ICO
    /// - Linux: PNG, JPEG, BMP, GIF, SVG, XPM (depends on system libraries)
    public static func fromFile(_ filePath: String) -> Image? {
        guard let handle = native_image_from_file(filePath) else {
            return nil
        }
        return Image(nativeHandle: handle) { native_image_destroy($0) }
    }
    
    /// Create an image from base64-encoded data.
    ///
    /// Decodes and loads an image from a base64-encoded string. The string
    /// can optionally include a data URI prefix (e.g., "data:image/png;base64,").
    ///
    /// Returns nil if decoding failed.
    ///
    /// The image format is automatically detected from the decoded data.
    public static func fromBase64(_ base64Data: String) -> Image? {
        guard let handle = native_image_from_base64(base64Data) else {
            return nil
        }
        return Image(nativeHandle: handle) { native_image_destroy($0) }
    }
    
    /// Get the size of the image in pixels.
    ///
    /// Returns a Size object with width and height, or Size.zero if invalid.
    public var size: Size {
        let nativeSize = native_image_get_size(nativeHandle)
        return Size(width: nativeSize.width, height: nativeSize.height)
    }
    
    /// Get the image format string for debugging purposes.
    ///
    /// Returns the image format (e.g., "PNG", "JPEG", "GIF"), or nil if unknown.
    public var format: String? {
        guard let formatPtr = native_image_get_format(nativeHandle) else {
            return nil
        }
        let format = String(cString: formatPtr)
        free_c_str(formatPtr)
        return format
    }
    
    /// Convert the image to base64-encoded PNG data.
    ///
    /// Returns base64-encoded PNG data with data URI prefix, or nil on error.
    public func toBase64() -> String? {
        guard let base64Ptr = native_image_to_base64(nativeHandle) else {
            return nil
        }
        let base64 = String(cString: base64Ptr)
        free_c_str(base64Ptr)
        return base64
    }
    
    /// Save the image to a file.
    ///
    /// Returns true if saved successfully, false otherwise.
    public func saveToFile(_ filePath: String) -> Bool {
        return native_image_save_to_file(nativeHandle, filePath)
    }
}
