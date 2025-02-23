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
      .package(name: "Rainbow", path: "../Rainbow"),
      .package(name: "swift-argument-parser", path: "../swift-argument-parser"),
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
