#!/usr/bin/env bash
#MISE description="Install the project dependencies"
set -eo pipefail

# Skip in CI - dependencies are installed explicitly in each workflow
if [ -n "$CI" ]; then
  exit 0
fi

pnpm install
swift package resolve
