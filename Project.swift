import ProjectDescription

let project = Project(name: "macker", targets: [
    .target(
        name: "macker",
        destinations: .macOS,
        product: .commandLineTool,
        bundleId: "io.tuist.macker",
        sources: [
            "Sources/macker/**/*.swift",
        ],
        dependencies: [
            .target(name: "MackerKit"),
        ]
    ),
    .target(
        name: "MackerKit",
        destinations: .macOS,
        product: .staticFramework,
        bundleId: "io.tuist.MackerKit",
        sources: [
            "Sources/MackerKit/**/*.swift",
        ],
        dependencies: [
        ],
        additionalFiles: [
            "README.md",
            "Sources/macker/macker.docc/**/*.md",
            "Sources/macker/macker.docc/**/*.tutorial",
            "Sources/macker/macker.docc/**/*.swift",
        ]
    ),
])
