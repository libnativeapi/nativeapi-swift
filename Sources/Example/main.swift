import Foundation
import nativeapi

// MARK: - Helper Functions

/// Convert display orientation to readable string
func orientationToString(_ orientation: nativeapi.DisplayOrientation) -> String {
    switch orientation {
    case .portrait:
        return "Portrait (0 deg)"
    case .landscape:
        return "Landscape (90 deg)"
    case .portraitFlipped:
        return "Portrait Flipped (180 deg)"
    case .landscapeFlipped:
        return "Landscape Flipped (270 deg)"
    @unknown default:
        return "Unknown"
    }
}

/// Truncate string if it's too long
func truncateString(_ str: String, maxLength: Int) -> String {
    if str.count <= maxLength {
        return str
    }
    let truncated = String(str.prefix(maxLength - 3))
    return truncated + "..."
}

/// Format a table row with proper alignment
func formatTableRow(_ content: String, totalWidth: Int = 70) -> String {
    let truncated = truncateString(content, maxLength: totalWidth - 4)
    let padding = totalWidth - 4 - truncated.count
    return "│ \(truncated)\(String(repeating: " ", count: padding)) │"
}

/// Create table border using ASCII characters
func createTableBorder(totalWidth: Int = 70) -> String {
    return "+" + String(repeating: "-", count: totalWidth - 2) + "+"
}

/// Print display information in a formatted table
func printDisplayInfo(_ display: nativeapi.Display) {
    let tableWidth = 70

    print(createTableBorder(totalWidth: tableWidth))
    print(formatTableRow("Display: \(display.name)", totalWidth: tableWidth))
    print(createTableBorder(totalWidth: tableWidth))
    print(formatTableRow("ID: \(display.id)", totalWidth: tableWidth))

    // Position
    let positionStr = "Position: (\(Int(display.position.x)), \(Int(display.position.y)))"
    print(formatTableRow(positionStr, totalWidth: tableWidth))

    // Size
    let sizeStr = "Size: \(Int(display.size.width)) x \(Int(display.size.height))"
    print(formatTableRow(sizeStr, totalWidth: tableWidth))

    // Work Area
    let workAreaStr =
        "Work Area: (\(Int(display.workArea.x)), \(Int(display.workArea.y))) \(Int(display.workArea.width)) x \(Int(display.workArea.height))"
    print(formatTableRow(workAreaStr, totalWidth: tableWidth))

    // Scale Factor
    let scaleStr = String(format: "Scale Factor: %.2f", display.scaleFactor)
    print(formatTableRow(scaleStr, totalWidth: tableWidth))

    // Primary status
    let primaryStr = "Primary: \(display.isPrimary ? "Yes" : "No")"
    print(formatTableRow(primaryStr, totalWidth: tableWidth))

    // Orientation
    let orientationStr = "Orientation: \(orientationToString(display.orientation))"
    print(formatTableRow(orientationStr, totalWidth: tableWidth))

    // Refresh Rate
    let refreshStr = "Refresh Rate: \(display.refreshRate) Hz"
    print(formatTableRow(refreshStr, totalWidth: tableWidth))

    // Bit Depth (if available)
    if display.bitDepth > 0 {
        let bitDepthStr = "Bit Depth: \(display.bitDepth) bits"
        print(formatTableRow(bitDepthStr, totalWidth: tableWidth))
    }

    // Manufacturer (if available)
    if !display.manufacturer.isEmpty {
        let manufacturerStr = "Manufacturer: \(display.manufacturer)"
        print(formatTableRow(manufacturerStr, totalWidth: tableWidth))
    }

    // Model (if available)
    if !display.model.isEmpty {
        let modelStr = "Model: \(display.model)"
        print(formatTableRow(modelStr, totalWidth: tableWidth))
    }

    print(createTableBorder(totalWidth: tableWidth))
}

// MARK: - Main Program

print("=== Native API Display Manager Demo ===")
print()

var displayManager = nativeapi.DisplayManager()

// Get all displays
let displays = displayManager.GetAll()

if displays.isEmpty {
    print("❌ No displays found!")
    exit(1)
}

print("📺 Found \(displays.count) display(s):")
print()

// Display primary display first
let primaryDisplay = displayManager.GetPrimary()
print("🌟 PRIMARY DISPLAY:")
printDisplayInfo(primaryDisplay)
print()

// Display secondary displays
let secondaryDisplays = displays.filter { !$0.isPrimary }
if !secondaryDisplays.isEmpty {
    print("📱 SECONDARY DISPLAYS:")
    for display in secondaryDisplays {
        printDisplayInfo(display)
        print()
    }
}

// Display cursor position
let cursorPosition = displayManager.GetCursorPosition()
print("🖱️  Current Cursor Position: (\(cursorPosition.x), \(cursorPosition.y))")
print()

// Display summary statistics
let totalWidth = displays.reduce(0) { $0 + $1.size.width }
let totalHeight = displays.map { $0.size.height }.max() ?? 0
let scaleFactors = displays.map { $0.scaleFactor }
let minScaleFactor = scaleFactors.min() ?? 0
let maxScaleFactor = scaleFactors.max() ?? 0

let summaryWidth = 60
print("📊 SUMMARY:")
print(createTableBorder(totalWidth: summaryWidth))

let totalDisplaysStr = "Total Displays: \(displays.count)"
print(formatTableRow(totalDisplaysStr, totalWidth: summaryWidth))

let combinedWidthStr = "Combined Width: \(Int(totalWidth))"
print(formatTableRow(combinedWidthStr, totalWidth: summaryWidth))

let maxHeightStr = "Max Height: \(Int(totalHeight))"
print(formatTableRow(maxHeightStr, totalWidth: summaryWidth))

let scaleRangeStr = String(format: "Scale Range: %.1fx - %.1fx", minScaleFactor, maxScaleFactor)
print(formatTableRow(scaleRangeStr, totalWidth: summaryWidth))

print(createTableBorder(totalWidth: summaryWidth))

print()
print("✅ Display information retrieved successfully!")
