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
        product: .staticFramework,
        bundleId: "io.tuist.SwiftTerminal",
        sources: [
            "Sources/SwiftTerminal/**/*.swift",
        ],
        dependencies: [
            .external(name: "Mockable")
        ],
        settings: .settings(configurations: [
            .debug(name: .debug, settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) MOCKING"]),
            .release(name: .release, settings: [:])
        ])
    ),
    .target(
        name: "SwiftTerminalTests",
        destinations: .macOS,
        product: .unitTests,
        bundleId: "io.tuist.SwiftTerminalTests",
        sources: [
            "Tests/SwiftTerminalTests/**/*.swift",
        ],
        dependencies: [
            .target(name: "SwiftTerminal"),
            .external(name: "MockableTest")
        ]
    )
])
