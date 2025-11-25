import Foundation
import NativeAPI
import Observation
import Shaft

// MARK: - Reusable UI Components

/// A card widget that displays key-value information
final class InfoCard: StatelessWidget {
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    let title: String
    let value: String

    func build(context: BuildContext) -> Widget {
        Column(crossAxisAlignment: .start, spacing: 4) {
            Text(title)
                .textStyle(
                    TextStyle(
                        color: Color(0xFF66_6666),
                        fontSize: 12
                    )
                )
            Text(value)
                .textStyle(
                    TextStyle(
                        color: Color(0xFF00_0000),
                        fontSize: 14,
                        fontWeight: .w600
                    )
                )
        }
        .padding(EdgeInsets.all(12))
        .boxDecoration(color: Color(0xFFF5_F5F5), borderRadius: .circular(6))
    }
}

/// A row that displays a property name and value
final class PropertyRow: StatelessWidget {
    init(label: String, value: String) {
        self.label = label
        self.value = value
    }

    let label: String
    let value: String

    func build(context: BuildContext) -> Widget {
        Row(mainAxisAlignment: .spaceBetween) {
            Text(label)
                .textStyle(
                    TextStyle(
                        color: Color(0xFF66_6666),
                        fontSize: 13
                    )
                )
            Text(value)
                .textStyle(
                    TextStyle(
                        color: Color(0xFF00_0000),
                        fontSize: 13,
                        fontWeight: .w500
                    )
                )
        }
        .padding(EdgeInsets.symmetric(vertical: 8))
    }
}

/// A styled section header
final class SectionHeader: StatelessWidget {
    init(_ title: String) {
        self.title = title
    }

    let title: String

    func build(context: BuildContext) -> Widget {
        Text(title)
            .textStyle(
                TextStyle(
                    color: Color(0xFF00_0000),
                    fontSize: 16,
                    fontWeight: .bold
                )
            )
            .padding(EdgeInsets.only(top: 16, bottom: 8))
    }
}

/// A view that displays an event history log
final class EventHistoryView: StatelessWidget {
    init(events: [String], maxEvents: Int = 20) {
        self.events = events
        self.maxEvents = maxEvents
    }

    let events: [String]
    let maxEvents: Int

    func build(context: BuildContext) -> Widget {
        if events.isEmpty {
            return Text("No events yet")
                .textStyle(
                    TextStyle(
                        color: Color(0xFF99_9999),
                        fontSize: 13
                    )
                )
                .center()
                .constrained(height: 100.0)
                .boxDecoration(color: Color(0xFFF5_F5F5), borderRadius: .circular(6))
        }

        return ListView {
            for event in events.prefix(maxEvents) {
                Text(event)
                    .textStyle(
                        TextStyle(
                            color: Color(0xFF33_3333),
                            fontFamily: "monospace",
                            fontSize: 11,
                        )
                    )
                    .padding(EdgeInsets.all(8))
                    .boxDecoration(color: Color(0xFFFF_FFFF), borderRadius: .circular(4))
                    .padding(EdgeInsets.only(bottom: 4))
            }
        }
        .padding(EdgeInsets.all(12))
        .boxDecoration(color: Color(0xFFF5_F5F5), borderRadius: .circular(6))
    }
}

// MARK: - Formatting Helpers

extension SharedHelpers {
    /// Format a size as "width × height"
    static func formatSize(_ size: NativeAPI.Size) -> String {
        return "\(Int(size.width)) × \(Int(size.height))"
    }

    /// Format a point as "(x, y)"
    static func formatPoint(_ point: NativeAPI.Point) -> String {
        return "(\(Int(point.x)), \(Int(point.y)))"
    }

    /// Format a timestamp for event logs
    static func formatTimestamp(_ date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    /// Format a boolean as "Yes" or "No"
    static func formatBool(_ value: Bool) -> String {
        return value ? "Yes" : "No"
    }
}

enum SharedHelpers {
    // Namespace for helper functions
}
