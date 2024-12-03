import ProjectDescription

let project = Project(
    name: "Noora",
    targets: [
        .target(
            name: "cli",
            destinations: .macOS,
            product: .commandLineTool,
            bundleId: "io.tuist.noora-cli",
            deploymentTargets: .macOS("12.0"),
            sources: [
                "Sources/cli/**/*.swift",
            ],
            dependencies: [
                .target(name: "Noora"),
                .external(name: "ArgumentParser"),
            ]
        ),
        .target(
            name: "Noora",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "io.tuist.Noora",
            deploymentTargets: .macOS("12.0"),
            sources: [
                "Sources/Noora/**/*.swift",
            ],
            dependencies: [
                .external(name: "Rainbow", condition: nil),
                .external(name: "CombineX", condition: nil),
                .external(name: "Asynchrone", condition: nil),
                .external(name: "Mockable"),
            ],
            settings: .settings(configurations: [
                .debug(
                    name: .debug,
                    settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) MOCKING"]
                ),
                .release(name: .release, settings: [:]),
            ])
        ),
        .target(
            name: "NooraTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "io.tuist.NooraTests",
            deploymentTargets: .macOS("12.0"),
            sources: [
                "Tests/NooraTests/**/*.swift",
            ],
            dependencies: [
                .target(name: "Noora"),
                .external(name: "Mockable"),
            ]
        ),
    ]
)
