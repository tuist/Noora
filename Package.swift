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
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.1.0")),
        .package(
            url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.5.0")
        ),
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.6.2")),
    ],
    targets: [
        .executableTarget(
            name: "examples-cli",
            dependencies: [
                "Noora", .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "Noora",
            dependencies: [
                "Rainbow",
                .product(name: "Logging", package: "swift-log")
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "NooraTests",
            dependencies: [
                "Noora",
            ]
        ),
    ]
)
