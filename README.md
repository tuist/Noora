# Noora ⭐️
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

Command Line Interfaces (CLIs), though graphically limited due to terminal capabilities, **can still benefit significantly from well-designed and consistent aesthetics across various commands**. This is a role traditionally filled by design systems in Graphical User Interfaces (GUIs), but it remains largely unexplored in the context of terminals.

Tuist's terminal experiences, for a long time, suffered from the lack of a design system, leading to issues like inconsistent spacing, information overload, and difficult-to-parse outputs. This situation motivated us to create SwiftTerminal, **a design system specifically for Swift-powered CLIs.**

Noora offers a set of aesthetically pleasing, customizable, and uniform design system for crafting terminal experiences. It encapsulates our extensive experience in crafting the Tuist CLI. We are delighted to share it with the Swift community, aiming to make building terminal experiences an enjoyable process.

> [!NOTE]
> The project is currently in an early stage of development. Our plan is to create a basic set of components and then iterate on them based on the feedback we receive from the community.

## Usage

Add `Noora` as a dependency of your project:

```swift
import PackageDescription

let package = Package(
    name: "Noora",
    platforms: [.macOS("12.0")],
    products: [
     /** Your products **/
    ],
    dependencies: [
      .package(url: "https://github.com/tuist/Noora", .upToNextMajor(from: "0.15.0")),
    ],
    targets: [
      /** Your targets **/
    ]
)
```

Then you can start using Noora.
You need to create an instance of `Noora` first, and then every component available is represented as a function in the `Noora` instance.

```swift
Noora().yesOrNoChoicePrompt(
  title: "Authentication",
  question: "Would you like to authenticate?",
  defaultAnswer: true,
  description: "Authentication is required to use some CLI features."
)
```

## Documentation

Check out [our documentation](https://noora.tuist.dev) to see the components and their usage.

## Development

### Using Tuist

1. Clone the repository: `git clone https://github.com/tuist/Noora.git`
2. Generate the project: `tuist generate`


### Using Swift Package Manager

1. Clone the repository: `git clone https://github.com/tuist/Noora.git`
2. Open the `Package.swift` with Xcode

## Documentation

To see the components and their usage, visit the [documentation website](https://noora.tuist.dev/).

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://finnvoorhees.com"><img src="https://avatars.githubusercontent.com/u/8284016?v=4?s=100" width="100px;" alt="Finn Voorhees"/><br /><sub><b>Finn Voorhees</b></sub></a><br /><a href="https://github.com/tuist/Noora/commits?author=finnvoor" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/VaishaliDesai"><img src="https://avatars.githubusercontent.com/u/16591961?v=4?s=100" width="100px;" alt="Vaishali Desai"/><br /><sub><b>Vaishali Desai</b></sub></a><br /><a href="https://github.com/tuist/Noora/commits?author=VaishaliDesai" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://nsvasilev.com"><img src="https://avatars.githubusercontent.com/u/17319991?v=4?s=100" width="100px;" alt="Nikita Vasilev"/><br /><sub><b>Nikita Vasilev</b></sub></a><br /><a href="https://github.com/tuist/Noora/commits?author=ns-vasilev" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!