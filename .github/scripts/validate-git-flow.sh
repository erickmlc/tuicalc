#!/usr/bin/env bash
set -euo pipefail

echo "=== Validating Git Flow Branch Naming ==="

# Extract branch name from GITHUB_REF or parameter
REF_NAME="${GITHUB_REF_NAME:-}"

if [[ -z "$REF_NAME" && $# -gt 0 ]]; then
    REF_NAME="$1"
fi

if [[ -z "$REF_NAME" ]]; then
    echo "::error::Branch name not provided."
    exit 1
fi

echo "Checking branch: '$REF_NAME'"

# Git Flow Branch Patterns:
# - main / master
# - develop / dev
# - feature/<name>
# - bugfix/<name>
# - hotfix/<name>
# - release/<version>
# - support/<name>
GIT_FLOW_REGEX='^(main|master|develop|dev|(feature|bugfix|hotfix|release|support)/[-a-zA-Z0-9_./]+)$'

if [[ ! "$REF_NAME" =~ $GIT_FLOW_REGEX ]]; then
    echo "::error::Branch '$REF_NAME' violates Git Flow naming conventions."
    echo "Allowed branch names:"
    echo "  - main | master | develop | dev"
    echo "  - feature/<feature-name>"
    echo "  - bugfix/<bugfix-name>"
    echo "  - hotfix/<hotfix-name>"
    echo "  - release/<version>"
    echo "  - support/<support-name>"
    exit 1
fi

echo "✓ Branch name complies with Git Flow."
