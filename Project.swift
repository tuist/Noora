import ProjectDescription

let project = Project(name: "TerminalUI", targets: [
    Target(name: "terminal-ui",
           platform: .macOS,
           product: .commandLineTool,
           bundleId: "io.tuist.terminal-ui",
           sources: [
            "Sources/terminal-ui/**/*.swift"
           ],
          dependencies: [
            .target(name: "TerminalUI")
          ]),
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
