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
                "src/screen_retriever_linux.cpp",
                "src/screen_retriever_windows.cpp",
            ],
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("Foundation")
            ]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
