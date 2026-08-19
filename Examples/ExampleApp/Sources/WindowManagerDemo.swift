import Foundation
import NativeAPI
import Observation
import Shaft

@Observable
class WindowManagerState {
    var windows: [Window] = []
    var eventHistory: [String] = []
    var selectedWindowId: Int?
    var lastUpdate: Date = Date()

    func addEvent(_ message: String) {
        let timestamp = SharedHelpers.formatTimestamp()
        eventHistory.insert("[\(timestamp)] \(message)", at: 0)
        if eventHistory.count > 20 {
            eventHistory.removeLast()
        }
    }
}

final class WindowManagerDemo: StatefulWidget {
    func createState() -> WindowManagerDemoState {
        WindowManagerDemoState()
    }
}

final class WindowManagerDemoState: State<WindowManagerDemo> {
    let state = WindowManagerState()
    var eventCallbackId: Int?
    var updateTimer: Foundation.Timer?

    override func initState() {
        super.initState()

        // Register for window events
        eventCallbackId = WindowManager.shared.shared.registerEventCallback { [weak self] event in
            guard let self = self else { return }
            self.handleWindowEvent(event)
        }

        // Start update timer
        updateTimer = Foundation.Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) {
            [weak self] _ in
            self?.updateWindows()
        }

        // Initial load
        updateWindows()
        state.addEvent("Window Manager initialized")
    }

    override func dispose() {
        if let callbackId = eventCallbackId {
            WindowManager.shared.shared.unregisterEventCallback(callbackId)
        }
        updateTimer?.invalidate()
        super.dispose()
    }

    private func handleWindowEvent(_ event: WindowEvent) {
        switch event.type {
        case .created:
            state.addEvent("Window created (ID: \(event.windowId))")
        case .closed:
            state.addEvent("Window closed (ID: \(event.windowId))")
        case .focused:
            state.addEvent("Window focused (ID: \(event.windowId))")
        case .blurred:
            state.addEvent("Window blurred (ID: \(event.windowId))")
        case .minimized:
            state.addEvent("Window minimized (ID: \(event.windowId))")
        case .maximized:
            state.addEvent("Window maximized (ID: \(event.windowId))")
        case .restored:
            state.addEvent("Window restored (ID: \(event.windowId))")
        case .moved(let position):
            state.addEvent(
                "Window moved to \(SharedHelpers.formatPoint(position)) (ID: \(event.windowId))"
            )
        case .resized(let size):
            state.addEvent(
                "Window resized to \(SharedHelpers.formatSize(size)) (ID: \(event.windowId))"
            )
        }
        updateWindows()
    }

    private func updateWindows() {
        let windowList = WindowManager.shared.shared.getAll()
        state.windows = windowList.windows
        state.lastUpdate = Date()
    }

    override func build(context: BuildContext) -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 16) {
            // Header
            buildHeader()

            // Content area with windows list and event history
            Expanded {
                Row(spacing: 16) {
                    // Windows list (2/3 width)
                    Expanded(flex: 2) {
                        buildWindowsList()
                    }

                    // Event history (1/3 width)
                    Expanded(flex: 1) {
                        buildEventHistory()
                    }
                }
            }
        }
        .padding(.all(16))
    }

    private func buildHeader() -> Widget {
        Row(mainAxisAlignment: .spaceBetween) {
            Column(crossAxisAlignment: .start, spacing: 4) {
                Text("Window Manager")
                    .textStyle(
                        TextStyle(
                            fontSize: 24,
                            fontWeight: .bold
                        )
                    )
                Text("\(state.windows.count) window\(state.windows.count == 1 ? "" : "s") detected")
                    .textStyle(
                        TextStyle(
                            color: Color(0xFF66_6666),
                            fontSize: 14
                        )
                    )
            }

            Button {
                self.updateWindows()
                self.state.addEvent("Manual refresh triggered")
            } child: {
                Text("Refresh")
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }

    private func buildWindowsList() -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 8) {
            SectionHeader("Windows")

            if state.windows.isEmpty {
                Expanded {
                    Text("No windows found")
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
                        for window in state.windows {
                            buildWindowCard(window)
                                .padding(EdgeInsets.only(bottom: 8))
                        }
                    }
                }
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }

    private func buildWindowCard(_ window: Window) -> Widget {
        let isSelected = state.selectedWindowId == window.id

        return GestureDetector(
            onTap: { [self] in
                state.selectedWindowId = window.id
                state.addEvent("Selected window \(window.id)")
            }
        ) {
            Column(crossAxisAlignment: .stretch, spacing: 8) {
                // Title and ID
                Row(mainAxisAlignment: .spaceBetween) {
                    Text(window.title.isEmpty ? "Window \(window.id)" : window.title)
                        .textStyle(
                            TextStyle(
                                fontSize: 16,
                                fontWeight: .bold
                            )
                        )
                    Text("#\(window.id)")
                        .textStyle(
                            TextStyle(
                                color: Color(0xFF99_9999),
                                fontSize: 12
                            )
                        )
                }

                // State indicators
                Row(spacing: 8) {
                    if window.isFocused {
                        buildBadge("Focused", Color(0xFF4C_AF50))
                    }
                    if window.isMinimized {
                        buildBadge("Minimized", Color(0xFFFF_9800))
                    }
                    if window.isMaximized {
                        buildBadge("Maximized", Color(0xFF21_96F3))
                    }
                    if window.isFullscreen {
                        buildBadge("Fullscreen", Color(0xFF9C_27B0))
                    }
                    if !window.isVisible {
                        buildBadge("Hidden", Color(0xFF75_7575))
                    }
                }

                HorizontalDivider()

                // Geometry info
                Column(spacing: 4) {
                    PropertyRow(
                        label: "Size",
                        value: SharedHelpers.formatSize(window.size)
                    )
                    PropertyRow(
                        label: "Position",
                        value: SharedHelpers.formatPoint(window.position)
                    )
                    PropertyRow(
                        label: "Opacity",
                        value: String(format: "%.2f", window.opacity)
                    )
                }

                HorizontalDivider()

                // Properties
                Column(spacing: 4) {
                    PropertyRow(
                        label: "Resizable",
                        value: SharedHelpers.formatBool(window.isResizable)
                    )
                    PropertyRow(
                        label: "Movable",
                        value: SharedHelpers.formatBool(window.isMovable)
                    )
                    PropertyRow(
                        label: "Always on Top",
                        value: SharedHelpers.formatBool(window.isAlwaysOnTop)
                    )
                }
            }
        }
        .padding(EdgeInsets.all(12))
        .boxDecoration(
            color: isSelected ? Color(0xFFE3_F2FD) : Color(0xFFF5_F5F5),
            borderRadius: .circular(8)
        )
    }

    private func buildBadge(_ text: String, _ color: Color) -> Widget {
        Text(text)
            .textStyle(
                TextStyle(
                    color: Color(0xFFFF_FFFF),
                    fontSize: 10,
                    fontWeight: .w600
                )
            )
            .padding(EdgeInsets.symmetric(vertical: 4, horizontal: 8))
            .boxDecoration(color: color, borderRadius: .circular(4))
    }

    private func buildEventHistory() -> Widget {
        Column(crossAxisAlignment: .stretch, spacing: 8) {
            SectionHeader("Event History")

            Expanded {
                EventHistoryView(events: state.eventHistory)
            }
        }
        .padding(EdgeInsets.all(16))
        .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(8))
    }
}
