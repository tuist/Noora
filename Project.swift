import ProjectDescription

let project = Project(name: "SwiftTerminal", targets: [
    .target(
        name: "swift-terminal",
        destinations: .macOS,
        product: .commandLineTool,
        bundleId: "io.tuist.swift-terminal",
        sources: [
            "Sources/swift-terminal/**/*.swift",
        ],
        dependencies: [
            .target(name: "SwiftTerminal"),
        ]
    ),
    .target(
        name: "SwiftTerminal",
        destinations: .macOS,
        product: .staticLibrary,
        bundleId: "io.tuist.SwiftTerminal",
        sources: [
            "Sources/SwiftTerminal/**/*.swift",
        ],
        dependencies: [
        ]
    ),
])
