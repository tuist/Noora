import ProjectDescription

let project = Project(name: "TerminalUI", targets: [
    Target(name: "TerminalUI",
           platform: .macOS,
           product: .staticLibrary,
           bundleId: "io.tuist.TerminalUI",
           sources: [
            "Sources/TerminalUI/**/*.swift"
           ],
          dependencies: [
            .external(name: "SwiftTUI")
          ])
])
