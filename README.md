# Noora Design System

Noora is Tuist's comprehensive design system that provides consistent UI components and patterns across all platforms and environments.

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->

[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-)

<!-- ALL-CONTRIBUTORS-BADGE:END -->

## Packages

This monorepo contains multiple packages that implement Noora's design principles:

### 📱 CLI Package (`packages/cli/`)

A Swift package providing terminal UI components for building beautiful command-line interfaces.

### 🌐 Web Package (`packages/web/`) _(Coming Soon)_

A package to build interactive user interfaces for the web using Phoenix LiveView.

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
mise run build-cli
mise run test-cli
mise run lint-cli
```

**Web Package (when available):**

```bash
mise run build-web
mise run test-web
mise run lint-web
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
