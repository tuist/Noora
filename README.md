# Noora Design System ⭐️

Noora is Tuist's comprehensive design system that provides consistent UI components and patterns across the web and the CLI.

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->

[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-)

<!-- ALL-CONTRIBUTORS-BADGE:END -->

> [!NOTE]
> The project is currently in an early stage of development. Our plan is to create a basic set of components and then iterate on them based on the feedback we receive from the community.

## Domains

Noora is implemented for CLIs and the web to achieve cohesive design across different environments. Noora for CLI is implemented as a Swift package whereas we chose Elixir and Phoenix for the web.

### 📱 CLI (`packages/cli/`)

Command Line Interfaces (CLIs), though graphically limited due to terminal capabilities, **can still benefit significantly from well-designed and consistent aesthetics across various commands**. This is a role traditionally filled by design systems in Graphical User Interfaces (GUIs), but it remains largely unexplored in the context of terminals.

Noora is a Swift package providing terminal UI components for building beautiful command-line interfaces. [Learn more →](./packages/cli/README.md)

### 🌐 Web (`packages/web/`) _(Coming Soon)_

A package to build interactive user interfaces for the web using Phoenix LiveView.

## Quick Start

### CLI Package

The Noora CLI package provides Swift components for building beautiful terminal interfaces. It includes components for:

- **Prompts**: Interactive user input (yes/no choices, text input, single choice selection)
- **Alerts**: Status messages (success, warning, error notifications)
- **Progress**: Visual progress indicators (progress bars, step indicators)
- **Text Styling**: Consistent typography and formatting

**Installation:**

```swift
.package(url: "https://github.com/tuist/Noora", .upToNextMajor(from: "0.15.0"))
```

**Usage:**

```swift
import Noora

Noora().yesOrNoChoicePrompt(
  title: "Authentication",
  question: "Would you like to authenticate?",
  defaultAnswer: true,
  description: "Authentication is required to use some CLI features."
)
```

For detailed installation instructions, usage examples, and component documentation, see the [CLI Package README](./packages/cli/README.md).

## Development

### Prerequisites

- [mise](https://mise.jdx.dev/) for tool management

### Getting Started

```bash
# Install tools
mise install

# Build all packages
mise run build

# Test all packages
mise run test

# Lint all packages
mise run lint
```

### Package-Specific Commands

**CLI Package:**

```bash
mise run cli:build
mise run cli:test
mise run cli:lint
```

## Documentation

- [CLI Package Documentation](./packages/cli/README.md)
- [Design Principles](./docs/content/index.md)
- [Component Gallery](./docs/content/components/)

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
