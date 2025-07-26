// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Noora",
    platforms: [.macOS("12.0")],
    products: [
        .library(
            name: "Noora",
            type: .static,
            targets: ["Noora"]
        ),
        .executable(
            name: "examples-cli",
            targets: ["examples-cli"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.2.0")),
        .package(
            url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.6.1")
        ),
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.6.4")),
        .package(url: "https://github.com/tuist/path", .upToNextMinor(from: "0.3.8")),
    ],
    targets: [
        .executableTarget(
            name: "examples-cli",
            dependencies: [
                "Noora", .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "cli/Sources/examples-cli"
        ),
        .target(
            name: "Noora",
            dependencies: [
                "Rainbow",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Path", package: "path"),
            ],
            path: "cli/Sources/Noora",
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "NooraTests",
            dependencies: [
                "Noora",
            ],
            path: "cli/Tests/NooraTests"
        ),
    ]
)
