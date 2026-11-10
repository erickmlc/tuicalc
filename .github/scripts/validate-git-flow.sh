#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/git-flow.sh"

echo "=== Validating Git Flow Branch Naming ==="

main() {
    # Extract branch name from GITHUB_REF_NAME or parameter
    local ref_name="${GITHUB_REF_NAME:-}"

    if [[ -z "$ref_name" && $# -gt 0 ]]; then
        ref_name="$1"
    fi

    validate_branch_name "$ref_name"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
