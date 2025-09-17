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
        .executable(name: "Example", targets: ["Example"]),
    ],
    targets: [
        .executableTarget(
            name: "Example",
            dependencies: ["NativeAPI"],
            path: "Examples/Example",
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
                    "src/platform/linux",
                    "src/platform/macos",
                    "src/platform/windows",
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
