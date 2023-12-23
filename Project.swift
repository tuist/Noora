import ProjectDescription

let project = Project(name: "SwiftTerminal", targets: [
    Target(name: "swift-terminal",
           platform: .macOS,
           product: .commandLineTool,
           bundleId: "io.tuist.swift-terminal",
           sources: [
            "Sources/swift-terminal/**/*.swift"
           ],
          dependencies: [
            .target(name: "SwiftTerminal")
          ]),
    Target(name: "SwiftTerminal",
           platform: .macOS,
           product: .staticLibrary,
           bundleId: "io.tuist.SwiftTerminal",
           sources: [
            "Sources/SwiftTerminal/**/*.swift"
           ],
          dependencies: [
            .external(name: "SwiftTUI")
          ])
])
