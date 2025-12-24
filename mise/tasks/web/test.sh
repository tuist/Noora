#!/bin/bash
# mise description="Runs the tests for the web package"
set -eo pipefail

pnpm -C web run test
