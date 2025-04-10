// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "nativeapi-swift",
    targets: [
        .executableTarget(
            name: "Example",
            dependencies: ["nativeapi"],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .target(
            name: "nativeapi",
            path: "Sources/libnativeapi",
            exclude: [
                "examples",
                "src/display_manager_linux.cpp",
                "src/display_manager_windows.cpp",
            ],
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("Foundation")
            ]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
