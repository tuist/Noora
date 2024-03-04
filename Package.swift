// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTerminal",
    platforms: [.macOS("11.0")],
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
        .package(url: "https://github.com/Kolos65/Mockable.git", .upToNextMinor(from: "0.0.2"))
    ],
    targets: [
        .executableTarget(name: "swift-terminal", dependencies: ["SwiftTerminal"]),
        .target(
            name: "SwiftTerminal",
            dependencies: [
                .product(name: "Mockable", package: "Mockable")
            ],
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug))
            ]
        ),
        .testTarget(
            name: "SwiftTerminalTests",
            dependencies: [
                "SwiftTerminal",
                .product(name: "MockableTest", package: "Mockable")
            ]
        ),
    ]
)
