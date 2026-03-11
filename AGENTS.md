# Noora CLI Design System

This file provides guidance to AI coding tools when working with code in this repository.

## Project Overview

Noora is a design system by Tuist that provides consistent UI components for CLI environments. This repository contains the Swift-based terminal UI components.

> **Note:** The web component library (Elixir/Phoenix LiveView) has moved to the [tuist/tuist](https://github.com/tuist/tuist) monorepo under the `noora/` directory.

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

### Key Directories
- `/cli/Sources/Noora/` - CLI library code
- `/docs/content/` - VitePress documentation
- `/mise/tasks/` - Build, test, and lint scripts

## Code Style

### CLI Development
- Use `Noorable` protocol for dependency injection and testing
- Theme system for consistent styling across components
- Validation framework with rules for user input
- Protocol-based testing enables easy mocking

## Testing
- CLI: Comprehensive test suite with mock implementations
- Use `mise run test` for full test suite

## Documentation
- Interactive documentation at https://noora.tuist.dev

## Security
- Never commit sensitive information (API keys, tokens) to the repository
- Follow security best practices for Swift development
- Use secure coding practices when handling user input in CLI prompts
