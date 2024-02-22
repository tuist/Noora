// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "macker",
    platforms: [.macOS("11.0")],
    products: [
        .library(
            name: "MackerKit",
            targets: ["MackerKit"]
        ),
        .executable(
            name: "macker",
            targets: ["macker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        .target(name: "macker", dependencies: ["MackerKit"]),
        .target(
            name: "MackerKit",
            dependencies: []
        ),
        .testTarget(
            name: "MackerKitTests",
            dependencies: ["MackerKit"]
        ),
    ]
)
