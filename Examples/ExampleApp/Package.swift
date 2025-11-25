// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExampleApp",

    platforms: [
        .macOS(.v14),
        .iOS(.v13),
        .tvOS(.v13),
    ],

    dependencies: [
        .package(
            url: "https://github.com/ShaftUI/Shaft",
            branch: "main"
        ),
        .package(url: "https://github.com/ShaftUI/SwiftReload.git", branch: "main"),
        .package(path: "../../"),  // nativeapi-swift
    ],

    targets: [
        .executableTarget(
            name: "ExampleApp",
            dependencies: [
                "SwiftReload",
                .product(name: "Shaft", package: "Shaft"),
                .product(name: "ShaftSetup", package: "Shaft"),
                .product(name: "NativeAPI", package: "nativeapi-swift"),
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),  // This is necessary to use the Skia renderer
                .unsafeFlags(
                    ["-Xfrontend", "-enable-private-imports"],
                    .when(configuration: .debug)
                ),
                .unsafeFlags(
                    ["-Xfrontend", "-enable-implicit-dynamic"],
                    .when(configuration: .debug)
                ),
            ],
            linkerSettings: [
                .unsafeFlags(
                    ["-Xlinker", "--export-dynamic"],
                    .when(platforms: [.linux, .android], configuration: .debug)
                )
            ]
        )
    ],
    cxxLanguageStandard: .cxx17  // This is necessary to use the Skia renderer
)
