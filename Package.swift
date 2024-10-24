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
            name: "cli",
            targets: ["cli"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.1")),
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/reddavis/Asynchrone", .upToNextMajor(from: "0.22.0")),
    ],
    targets: [
        .executableTarget(name: "cli", dependencies: ["Noora"]),
        .target(
            name: "Noora",
            dependencies: [
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "CombineX", package: "CombineX"),
                .product(name: "Asynchrone", package: "Asynchrone"),
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
