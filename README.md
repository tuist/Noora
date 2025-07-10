# Noora Design System ⭐️

Noora is Tuist's comprehensive design system that provides consistent UI components and patterns across the web and the CLI.

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-4-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

> [!NOTE]
> The project is currently in an early stage of development. Our plan is to create a basic set of components and then iterate on them based on the feedback we receive from the community.

## Domains

Noora is implemented for CLIs and the web to achieve cohesive design across different environments. Noora for CLI is implemented as a Swift package whereas we chose Elixir and Phoenix for the web.

### 📱 [CLI](https://noora.tuist.dev/)

Command Line Interfaces (CLIs), though graphically limited due to terminal capabilities, **can still benefit significantly from well-designed and consistent aesthetics across various commands**. This is a role traditionally filled by design systems in Graphical User Interfaces (GUIs), but it remains largely unexplored in the context of terminals.

Noora is a Swift package providing terminal UI components for building beautiful command-line interfaces. [Learn more →](./cli/README.md)

### 🌐 Web

A component library for building web applications with Phoenix LiveView — bringing Noora's design consistency to the web. [Learn more →](./web/README.md)

## Quick Start

### CLI

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

[View full CLI documentation →](https://noora.tuist.dev/)

### Web

The Noora web package provides Phoenix LiveView components for building beautiful web interfaces.

**Installation:**

Add to your `mix.exs`:

```elixir
{:noora, "~> 0.1.0"}
```

Import styles in `assets/css/app.css`:

```css
@import "noora/noora.css";
```

Configure hooks in `assets/js/app.js`:

```javascript
import Noora from "noora";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...Noora },
});
```

[View full web documentation →](https://hexdocs.pm/noora/)

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
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rmenezes"><img src="https://avatars.githubusercontent.com/u/1154679?v=4?s=100" width="100px;" alt="Raul Menezes"/><br /><sub><b>Raul Menezes</b></sub></a><br /><a href="https://github.com/tuist/Noora/commits?author=rmenezes" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
