// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTerminal",
    products: [
        .library(
            name: "SwiftTerminal",
            targets: ["SwiftTerminal"]),
        .executable(name: "swift-terminal",
                    targets: ["swift-terminal"])
    ],
    targets: [
        .target(name: "swift-terminal", dependencies: ["SwiftTerminal"]),
        .target(
            name: "SwiftTerminal"),
        .testTarget(
            name: "SwiftTerminalTests",
            dependencies: ["SwiftTerminal"]),
    ]
)
