// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTerminal",
    platforms: [.macOS("11.0")],
    products: [
        .library(
            name: "SwiftTerminal",
            targets: ["SwiftTerminal"]
        ),
        .executable(
            name: "swift-terminal",
            targets: ["swift-terminal"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "swift-terminal", dependencies: ["SwiftTerminal"]),
        .target(
            name: "SwiftTerminal",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftTerminalTests",
            dependencies: ["SwiftTerminal"]
        ),
    ]
)
