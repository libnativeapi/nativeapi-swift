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
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .target(
            name: "CNativeAPI",
            path: "Sources/libnativeapi",
            exclude: {
                var excluded = ["examples"]
                #if os(Linux)
                    excluded.append(contentsOf: ["src/platform/macos", "src/platform/windows"])
                #elseif os(macOS)
                    excluded.append(contentsOf: ["src/platform/linux", "src/platform/windows"])
                #elseif os(Windows)
                    excluded.append(contentsOf: ["src/platform/macos", "src/platform/linux"])
                #endif
                return excluded
            }(),
            linkerSettings: {
                #if os(macOS) || os(iOS)
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
