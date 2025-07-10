#!/usr/bin/env bash
#MISE description="Install the project dependencies"

pnpm install
swift package resolve
(cd storybook && mix deps.get)
(cd web && mix deps.get)
