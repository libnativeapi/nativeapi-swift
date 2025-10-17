import Foundation
import CNativeAPI

/// A cross-platform image class for handling images across different platforms.
///
/// This class provides a unified interface for working with images and supports
/// multiple initialization methods including file paths, base64-encoded data,
/// and system icons.
///
/// Features:
/// - Load images from file paths
/// - Load images from base64-encoded strings
/// - Platform-specific system icon support
/// - Automatic format detection and conversion
/// - Memory-efficient internal representation
///
/// All Image instances must be created using static factory methods
/// (fromFile, fromBase64, fromSystemIcon).
///
/// Example:
/// ```swift
/// // Create image from file path
/// let image1 = Image.fromFile("/path/to/icon.png")
///
/// // Create image from base64 string
/// let image2 = Image.fromBase64("data:image/png;base64,iVBORw0KGgo...")
///
/// // Create image from system icon
/// let image3 = Image.fromSystemIcon("folder")
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
    
    /// Create an image from a platform-specific system icon.
    ///
    /// Loads a system icon using platform-specific icon names/identifiers.
    ///
    /// Returns nil if icon not found.
    ///
    /// Platform-specific icon names:
    /// - macOS: "NSApplicationIcon", "NSFolder", "NSDocument", etc.
    /// - Windows: "IDI_APPLICATION", "IDI_INFORMATION", "IDI_WARNING", etc.
    /// - Linux: Depends on the desktop environment and icon theme
    public static func fromSystemIcon(_ iconName: String) -> Image? {
        guard let handle = native_image_from_system_icon(iconName) else {
            return nil
        }
        return Image(nativeHandle: handle) { native_image_destroy($0) }
    }
    
    /// Create an image from a Flutter asset.
    ///
    /// Loads an image from the Flutter assets bundle. This method automatically
    /// resolves the correct asset path based on the current platform.
    ///
    /// The asset path is constructed differently for each platform:
    /// - macOS: Located in App.framework/Resources/flutter_assets/
    /// - Other platforms: Located in data/flutter_assets/ relative to executable
    ///
    /// Returns nil if the asset file is not found or loading failed.
    ///
    /// Example:
    /// ```swift
    /// // Load an image asset (assumes assets/icons/app_icon.png exists)
    /// let appIcon = Image.fromAsset("assets/icons/app_icon.png")
    /// if let appIcon = appIcon {
    ///   trayIcon.icon = appIcon
    /// }
    ///
    /// // Load a simple asset
    /// let logo = Image.fromAsset("images/logo.svg")
    /// ```
    ///
    /// Note: The asset must be included in your pubspec.yaml file:
    /// ```yaml
    /// flutter:
    ///   assets:
    ///     - assets/icons/
    ///     - images/
    /// ```
    public static func fromAsset(_ name: String) -> Image? {
        // Get the path to the current executable
        let executablePath = Bundle.main.executablePath ?? ""
        
        // Default asset path for most platforms (Windows, Linux)
        var assetPath = URL(fileURLWithPath: executablePath)
            .deletingLastPathComponent()
            .appendingPathComponent("data/flutter_assets")
            .appendingPathComponent(name)
            .path
        
        // macOS has a different bundle structure
        #if os(macOS)
        if executablePath.contains(".app") {
            // On macOS, assets are located in the app bundle's framework resources
            assetPath = URL(fileURLWithPath: executablePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("Frameworks")
                .appendingPathComponent("App.framework")
                .appendingPathComponent("Resources")
                .appendingPathComponent("flutter_assets")
                .appendingPathComponent(name)
                .path
        }
        #endif
        
        // Load the image from the resolved asset path
        return fromFile(assetPath)
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
