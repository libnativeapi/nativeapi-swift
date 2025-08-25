// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "nativeapi",
    products: [
        .library(name: "nativeapi", targets: ["nativeapi"])
    ],
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
                "src/platform/linux",
                "src/platform/windows",
            ],
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("Foundation"),
            ]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
