#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/git-flow.sh"

echo "=== Validating Git Flow Branch Naming ==="

main() {
    # Extract branch name from parameter or GITHUB_REF_NAME
    local ref_name="${1:-${GITHUB_REF_NAME:-}}"

    validate_branch_name "$ref_name"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
