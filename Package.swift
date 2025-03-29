// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "nativeapi",
    targets: [
        .executableTarget(
            name: "Example",
            dependencies: ["libnativeapi"],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .target(
            name: "libnativeapi",
            exclude: [
                "examples",
                "src/screen_retriever_linux.cpp",
                "src/screen_retriever_linux.h",
                "src/screen_retriever_windows.cpp",
                "src/screen_retriever_windows.h",
            ],
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("Foundation")
            ]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
