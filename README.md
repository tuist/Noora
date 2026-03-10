# Noora CLI

Noora is a Swift package providing terminal UI components for building beautiful command-line interfaces.

> [!NOTE]
> The web component library has moved to the [tuist/tuist](https://github.com/tuist/tuist) monorepo (`noora/` directory).

## Quick Start

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

The Noora CLI package provides Swift components for building beautiful terminal interfaces. It includes components for:

- **Prompts**: Interactive user input (yes/no choices, text input, single choice selection)
- **Alerts**: Status messages (success, warning, error notifications)
- **Progress**: Visual progress indicators (progress bars, step indicators)
- **Text Styling**: Consistent typography and formatting

[View full CLI documentation](https://noora.tuist.dev/)

## Development

### Prerequisites

- [mise](https://mise.jdx.dev/) for tool management

### Getting Started

```bash
# Install tools
mise install

# Build
mise run build

# Test
mise run test

# Lint
mise run lint
```

## Contributors

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
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mikhailmulyar"><img src="https://avatars.githubusercontent.com/u/2234720?v=4?s=100" width="100px;" alt="Mikhail"/><br /><sub><b>Mikhail</b></sub></a><br /><a href="https://github.com/tuist/Noora/commits?author=mikhailmulyar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Joannis"><img src="https://avatars.githubusercontent.com/u/1951674?v=4?s=100" width="100px;" alt="Joannis Orlandos"/><br /><sub><b>Joannis Orlandos</b></sub></a><br /><a href="https://github.com/tuist/Noora/commits?author=Joannis" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/zamderax"><img src="https://avatars.githubusercontent.com/u/175750746?v=4?s=100" width="100px;" alt="Zamderax"/><br /><sub><b>Zamderax</b></sub></a><br /><a href="https://github.com/tuist/Noora/commits?author=zamderax" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="http://sbryu.com"><img src="https://avatars.githubusercontent.com/u/87907656?v=4?s=100" width="100px;" alt="Ryu"/><br /><sub><b>Ryu</b></sub></a><br /><a href="https://github.com/tuist/Noora/commits?author=Ryu0118" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
