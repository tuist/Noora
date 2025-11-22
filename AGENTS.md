# Noora Design System

This file provides guidance to AI coding tools when working with code in this repository.

## Project Overview

Noora is a comprehensive design system by Tuist that provides consistent UI components for both CLI and web environments. It's a monorepo with Swift-based terminal UI components and Elixir/Phoenix LiveView web components.

## Build & Commands

All commands use `mise` for task management:

**Build & Test:**
```bash
mise run build          # Build all packages
mise run test           # Test all packages
mise run lint           # Lint all packages (add --fix to auto-fix)
```

**Package-specific commands:**
```bash
# CLI (Swift)
mise run cli:build
mise run cli:test
mise run cli:lint

# Web (Elixir/Phoenix)
mise run web:build
mise run web:lint

# Documentation
mise run docs:dev       # Start development server
mise run docs:build
mise run docs:deploy    # Deploy to Cloudflare Pages
```

## Architecture

### CLI Package (`/cli/`)
- **Language**: Swift (macOS 12.0+)
- **Architecture**: Protocol-oriented design with `Noorable` protocol for testing
- **Components**: Prompts, Alerts, Progress indicators, Validation framework
- **Dependencies**: Rainbow (colors), swift-argument-parser, swift-log, Path
- **Testing**: Mock implementations via protocols, comprehensive test suite

### Web Package (`/web/`)
- **Language**: Elixir/Phoenix LiveView
- **Architecture**: Component-based with Phoenix Components
- **Styling**: CSS custom properties for theming
- **JavaScript**: Zag.js state machines for interactive components
- **Dependencies**: Phoenix (~> 1.7.12), Phoenix LiveView (~> 1.0.0)

### Key Directories
- `/cli/Sources/Noora/` - CLI library code
- `/web/lib/noora/` - Phoenix components
- `/docs/content/` - VitePress documentation
- `/storybook/` - Phoenix LiveView storybook for component development
- `/mise/tasks/` - Build, test, and lint scripts

## Code Style

### CLI Development
- Use `Noorable` protocol for dependency injection and testing
- Theme system for consistent styling across components
- Validation framework with rules for user input
- Protocol-based testing enables easy mocking

### Web Development
- Phoenix Component architecture with slots and attributes
- CSS custom properties for theming consistency
- JavaScript hooks using Zag.js state machines for complex interactions
- Component composition through slots and attributes

## Testing
- CLI: Comprehensive test suite with mock implementations
- Web: Component testing within Phoenix LiveView context
- Use `mise run test` for full test suite across all packages

## Documentation
- Interactive documentation at https://noora.tuist.dev
- API documentation generated with ExDoc for web components
- Storybook for component development and visual testing

## Security
- Never commit sensitive information (API keys, tokens) to the repository
- Follow security best practices for both Swift and Elixir/Phoenix development
- Use secure coding practices when handling user input in CLI prompts