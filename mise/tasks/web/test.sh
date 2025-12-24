#!/bin/bash
# mise description="Runs the tests for the web package"
set -euo pipefail

pnpm -C web run test
