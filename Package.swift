// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTerminal",
    platforms: [.macOS("12.0")],
    products: [
        .library(
            name: "SwiftTerminal",
            type: .static,
            targets: ["SwiftTerminal"]
        ),
        .executable(
            name: "swift-terminal",
            targets: ["swift-terminal"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.1")),
        .package(url: "https://github.com/cx-org/CombineX", .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/reddavis/Asynchrone", .upToNextMajor(from: "0.22.0")),
    ],
    targets: [
        .executableTarget(name: "swift-terminal", dependencies: ["SwiftTerminal"]),
        .target(
            name: "SwiftTerminal",
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
            name: "SwiftTerminalTests",
            dependencies: [
                "SwiftTerminal",
            ]
        ),
    ]
)
