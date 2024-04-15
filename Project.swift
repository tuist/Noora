import ProjectDescription

let project = Project(name: "SwiftTerminal", targets: [
    .target(
        name: "swift-terminal",
        destinations: .macOS,
        product: .commandLineTool,
        bundleId: "io.tuist.swift-terminal",
        deploymentTargets: .macOS("12.0"),
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
        deploymentTargets: .macOS("12.0"),
        sources: [
            "Sources/SwiftTerminal/**/*.swift",
        ],
        dependencies: [
            .external(name: "Rainbow", condition: nil),
            .external(name: "CombineX", condition: nil),
        ],
        settings: .settings(configurations: [
            .debug(name: .debug, settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) MOCKING"]),
            .release(name: .release, settings: [:]),
        ])
    ),
    .target(
        name: "SwiftTerminalTests",
        destinations: .macOS,
        product: .unitTests,
        bundleId: "io.tuist.SwiftTerminalTests",
        deploymentTargets: .macOS("12.0"),
        sources: [
            "Tests/SwiftTerminalTests/**/*.swift",
        ],
        dependencies: [
            .target(name: "SwiftTerminal"),
        ]
    ),
])
