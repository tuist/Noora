# Noora CLI ⭐️

A Swift package providing terminal UI components for building beautiful command-line interfaces.

Command Line Interfaces (CLIs), though graphically limited due to terminal capabilities, **can still benefit significantly from well-designed and consistent aesthetics across various commands**. This is a role traditionally filled by design systems in Graphical User Interfaces (GUIs), but it remains largely unexplored in the context of terminals.

Tuist's terminal experiences, for a long time, suffered from the lack of a design system, leading to issues like inconsistent spacing, information overload, and difficult-to-parse outputs. This situation motivated us to create **a design system specifically for Swift-powered CLIs.**

Noora offers a set of aesthetically pleasing, customizable, and uniform design system for crafting terminal experiences. It encapsulates our extensive experience in crafting the Tuist CLI. We are delighted to share it with the Swift community, aiming to make building terminal experiences an enjoyable process.

> [!NOTE]
> The project is currently in an early stage of development. Our plan is to create a basic set of components and then iterate on them based on the feedback we receive from the community.

## Installation

Add `Noora` as a dependency of your Swift project:

```swift
import PackageDescription

let package = Package(
    name: "YourProject",
    platforms: [.macOS("12.0")],
    products: [
     /** Your products **/
    ],
    dependencies: [
      .package(url: "https://github.com/tuist/Noora", .upToNextMajor(from: "0.15.0")),
    ],
    targets: [
      .target(
        name: "YourTarget",
        dependencies: ["Noora"]
      )
    ]
)
```

## Usage

You need to create an instance of `Noora` first, and then every component available is represented as a function in the `Noora` instance.

```swift
import Noora

Noora().yesOrNoChoicePrompt(
  title: "Authentication",
  question: "Would you like to authenticate?",
  defaultAnswer: true,
  description: "Authentication is required to use some CLI features."
)
```

## Components

Noora CLI provides a comprehensive set of components for building beautiful terminal interfaces. Check out [our documentation](https://noora.tuist.dev) to see all available components and their usage.

## Development

### Using Swift Package Manager

1. Clone the repository: `git clone https://github.com/tuist/Noora.git`
2. Open the `cli/Package.swift` with Xcode

### Tasks

```bash
mise run cli:build
mise run cli:test
mise run cli:lint
```
