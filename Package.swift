// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTerminal",
    platforms: [.macOS("10.15")],
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
        .package(url: "https://github.com/rensbreur/SwiftTUI.git", .revision("9ae1ac9f2f4070a1186e7f4adafebe9bf1beedff")),
    ],
    targets: [
        .target(name: "swift-terminal", dependencies: ["SwiftTerminal"]),
        .target(
            name: "SwiftTerminal",
            dependencies: ["SwiftTUI"]
        ),
        .testTarget(
            name: "SwiftTerminalTests",
            dependencies: ["SwiftTerminal"]
        ),
    ]
)
