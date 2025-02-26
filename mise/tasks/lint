#!/bin/bash
# mise description="Lint the project using SwiftLint and SwiftFormat"
#USAGE flag "-f --fix" help="Fix the fixable issues"

set -eo pipefail

if [ "$usage_fix" = "true" ]; then
    swiftformat $MISE_PROJECT_ROOT
    swiftlint lint --fix --quiet --config $MISE_PROJECT_ROOT/.swiftlint.yml $MISE_PROJECT_ROOT/Sources
else
    swiftformat $MISE_PROJECT_ROOT --lint
    swiftlint lint --quiet --config $MISE_PROJECT_ROOT/.swiftlint.yml $MISE_PROJECT_ROOT/Sources
fi
