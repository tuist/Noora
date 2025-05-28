# Noora Design System

Noora is Tuist's comprehensive design system that provides consistent UI components and patterns across all platforms and environments.

## Packages

This monorepo contains multiple packages that implement Noora's design principles:

### 📱 CLI Package (`packages/cli/`)

A Swift package providing terminal UI components for building beautiful command-line interfaces.

### 🌐 Web Package (`packages/web/`) _(Coming Soon)_

A package to build interactive user interfaces for the web using Phoenix LiveView.

## Development

### Prerequisites

- [mise](https://mise.jdx.dev/) for tool management
- Swift 6.0+ (for CLI package)
- Node.js 22+ (for web package)

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

## Contributing

We welcome contributions! Please see our contributing guidelines and code of conduct.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

