// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "NativeAPI",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(name: "NativeAPI", targets: ["NativeAPI"]),
        .executable(name: "AccessibilityExample", targets: ["AccessibilityExample"]),
        .executable(name: "ApplicationExample", targets: ["ApplicationExample"]),
        .executable(name: "DisplayExample", targets: ["DisplayExample"]),
        .executable(name: "KeyboardExample", targets: ["KeyboardExample"]),
        .executable(name: "LaunchAtLoginExample", targets: ["LaunchAtLoginExample"]),
        .executable(name: "MenuExample", targets: ["MenuExample"]),
        .executable(name: "MessageDialogExample", targets: ["MessageDialogExample"]),
        .executable(name: "ShortcutExample", targets: ["ShortcutExample"]),
        .executable(name: "StorageExample", targets: ["StorageExample"]),
        .executable(name: "TrayIconExample", targets: ["TrayIconExample"]),
        .executable(name: "UrlOpenerExample", targets: ["UrlOpenerExample"]),
        .executable(name: "WindowExample", targets: ["WindowExample"]),
    ],
    targets: [
        .executableTarget(
            name: "AccessibilityExample",
            dependencies: ["NativeAPI"],
            path: "Examples/AccessibilityExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "ApplicationExample",
            dependencies: ["NativeAPI"],
            path: "Examples/ApplicationExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "DisplayExample",
            dependencies: ["NativeAPI"],
            path: "Examples/DisplayExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "KeyboardExample",
            dependencies: ["NativeAPI"],
            path: "Examples/KeyboardExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "LaunchAtLoginExample",
            dependencies: ["NativeAPI"],
            path: "Examples/LaunchAtLoginExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "MenuExample",
            dependencies: ["NativeAPI"],
            path: "Examples/MenuExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "MessageDialogExample",
            dependencies: ["NativeAPI"],
            path: "Examples/MessageDialogExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "ShortcutExample",
            dependencies: ["NativeAPI"],
            path: "Examples/ShortcutExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "StorageExample",
            dependencies: ["NativeAPI"],
            path: "Examples/StorageExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "TrayIconExample",
            dependencies: ["NativeAPI"],
            path: "Examples/TrayIconExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "UrlOpenerExample",
            dependencies: ["NativeAPI"],
            path: "Examples/UrlOpenerExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .executableTarget(
            name: "WindowExample",
            dependencies: ["NativeAPI"],
            path: "Examples/WindowExample",
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .target(
            name: "CNativeAPI",
            path: "Sources/CNativeAPI",
            exclude: {
                var excluded = [
                    "examples",
                    "src/platform/android",
                    "src/platform/ios",
                    "src/platform/linux",
                    "src/platform/macos",
                    "src/platform/ohos",
                    "src/platform/windows",
                    "tests",
                ]
                #if os(Linux)
                    excluded.removeAll { $0 == "src/platform/linux" }
                #elseif os(macOS)
                    excluded.removeAll { $0 == "src/platform/macos" }
                #elseif os(Windows)
                    excluded.removeAll { $0 == "src/platform/windows" }
                #endif
                return excluded
            }(),
            linkerSettings: {
                #if os(macOS)
                    return [
                        .linkedFramework("Cocoa"),
                        .linkedFramework("Foundation"),
                        .linkedFramework("Carbon"),
                        .linkedFramework("ServiceManagement"),
                    ]
                #else
                    return []
                #endif
            }()
        ),
        .target(
            name: "NativeAPI",
            dependencies: ["CNativeAPI"],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .testTarget(
            name: "NativeAPITests",
            dependencies: ["NativeAPI"],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
