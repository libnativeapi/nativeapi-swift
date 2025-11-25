import Foundation
import NativeAPI
import Observation
import Shaft

@Observable
class DisplayManagerState {
    var displays: [Display] = []
    var cursorPosition: Point = Point(x: 0, y: 0)
    var currentWindow: Window?
    var lastUpdate: Date = Date()
}

final class DisplayManagerDemo: StatefulWidget {
    func createState() -> DisplayManagerDemoState {
        DisplayManagerDemoState()
    }
}

final class DisplayManagerDemoState: State<DisplayManagerDemo> {
    let state = DisplayManagerState()
    var updateTimer: Foundation.Timer?

    override func initState() {
        super.initState()

        // Start update timer
        updateTimer = Foundation.Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            [weak self] _ in
            self?.updateDisplayInfo()
        }

        // Initial load
        self.updateDisplayInfo()
    }

    override func dispose() {
        updateTimer?.invalidate()
        super.dispose()
    }

    private func updateDisplayInfo() {
        state.displays = DisplayManager.shared.getAll()
        state.cursorPosition = DisplayManager.shared.getCursorPosition()
        state.currentWindow = WindowManager.shared.getCurrent()
        state.lastUpdate = Date()
    }

    override func build(context: BuildContext) -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 16) {
            // Header
            buildHeader()

            // Content area with displays and cursor info
            Expanded {
                Row(spacing: 16) {
                    // Displays list (2/3 width)
                    Expanded(flex: 2) {
                        buildDisplaysList()
                    }

                    // Cursor and current window info (1/3 width)
                    Expanded(flex: 1) {
                        Column(spacing: 16) {
                            buildCursorInfo()
                            buildCurrentWindowInfo()
                        }
                    }
                }
            }
        }
        .padding(.all(16))
    }

    private func buildHeader() -> Widget {
        Row(mainAxisAlignment: .spaceBetween) {
            Column(crossAxisAlignment: .start, spacing: 4) {
                Text("Display Manager")
                    .textStyle(
                        TextStyle(
                            fontSize: 24,
                            fontWeight: .bold
                        )
                    )
                Text(
                    "\(state.displays.count) display\(state.displays.count == 1 ? "" : "s") detected"
                )
                .textStyle(
                    TextStyle(
                        color: Color(0xFF66_6666),
                        fontSize: 14
                    )
                )
            }

            Button {
                self.updateDisplayInfo()
            } child: {
                Text("Refresh")
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }

    private func buildDisplaysList() -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 8) {
            SectionHeader("Displays")

            if state.displays.isEmpty {
                Expanded {
                    Text("No displays found")
                        .textStyle(
                            TextStyle(
                                color: Color(0xFF99_9999),
                                fontSize: 14
                            )
                        )
                        .center()
                }
            } else {
                Expanded {
                    ListView {
                        for display in state.displays {
                            buildDisplayCard(display)
                                .padding(EdgeInsets.only(bottom: 8))
                        }
                    }
                }
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }

    private func buildDisplayCard(_ display: Display) -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 12) {
            // Display name and primary indicator
            Row(mainAxisAlignment: .spaceBetween) {
                Text(display.name)
                    .textStyle(
                        TextStyle(
                            fontSize: 16,
                            fontWeight: .bold
                        )
                    )
                if display.isPrimary {
                    Text("PRIMARY")
                        .textStyle(
                            TextStyle(
                                color: Color(0xFFFF_FFFF),
                                fontSize: 10,
                                fontWeight: .w600
                            )
                        )
                        .padding(EdgeInsets.symmetric(vertical: 4, horizontal: 8))
                        .boxDecoration(color: Color(0xFF4C_AF50), borderRadius: .circular(4))
                }

                // Display ID
                PropertyRow(label: "ID", value: display.id)

                HorizontalDivider()

                // Resolution and geometry
                SectionHeader("Geometry")
                Column(spacing: 4) {
                    PropertyRow(
                        label: "Resolution",
                        value: SharedHelpers.formatSize(display.size)
                    )
                    PropertyRow(
                        label: "Position",
                        value: SharedHelpers.formatPoint(display.position)
                    )
                    PropertyRow(
                        label: "Work Area Size",
                        value: SharedHelpers.formatSize(
                            Size(
                                width: display.workArea.width,
                                height: display.workArea.height
                            )
                        )
                    )
                    PropertyRow(
                        label: "Work Area Position",
                        value: "(\(Int(display.workArea.left)), \(Int(display.workArea.top)))"
                    )
                }

                HorizontalDivider()

                // Hardware properties
                SectionHeader("Hardware")
                Column(spacing: 4) {
                    PropertyRow(
                        label: "Scale Factor",
                        value: String(format: "%.2f×", display.scaleFactor)
                    )
                    PropertyRow(
                        label: "Refresh Rate",
                        value: "\(display.refreshRate) Hz"
                    )
                    PropertyRow(
                        label: "Bit Depth",
                        value: "\(display.bitDepth) bit"
                    )
                    PropertyRow(
                        label: "Orientation",
                        value: orientationString(display.orientation)
                    )
                }
            }
        }
        .padding(EdgeInsets.all(12))
        .boxDecoration(
            color: display.isPrimary ? Color(0xFFE8_F5E9) : Color(0xFFF5_F5F5),
            borderRadius: .circular(8)
        )
    }

    private func buildCursorInfo() -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 8) {
            SectionHeader("Cursor Position")

            Column(spacing: 8) {
                InfoCard(
                    title: "X",
                    value: String(format: "%.1f", state.cursorPosition.x)
                )
                InfoCard(
                    title: "Y",
                    value: String(format: "%.1f", state.cursorPosition.y)
                )
            }

            Text("Updates in real-time")
                .textStyle(
                    TextStyle(
                        color: Color(0xFF99_9999),
                        fontSize: 11
                    )
                )
                .padding(EdgeInsets.only(top: 4))
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }

    private func buildCurrentWindowInfo() -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 8) {
            SectionHeader("Current Window")

            if let window = state.currentWindow {
                Column(spacing: 8) {
                    PropertyRow(
                        label: "ID",
                        value: String(window.id)
                    )
                    PropertyRow(
                        label: "Title",
                        value: window.title.isEmpty ? "(No title)" : window.title
                    )
                    PropertyRow(
                        label: "Size",
                        value: SharedHelpers.formatSize(window.size)
                    )
                    PropertyRow(
                        label: "Position",
                        value: SharedHelpers.formatPoint(window.position)
                    )
                    PropertyRow(
                        label: "Focused",
                        value: SharedHelpers.formatBool(window.isFocused)
                    )
                }
            } else {
                Text("No window focused")
                    .textStyle(
                        TextStyle(
                            color: Color(0xFF99_9999),
                            fontSize: 13
                        )
                    )
                    .padding(EdgeInsets.symmetric(vertical: 16))
                    .center()
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }

    private func orientationString(_ orientation: DisplayOrientation) -> String {
        switch orientation {
        case .portrait:
            return "Portrait"
        case .landscape:
            return "Landscape"
        case .portraitFlipped:
            return "Portrait (Flipped)"
        case .landscapeFlipped:
            return "Landscape (Flipped)"
        }
    }
}
