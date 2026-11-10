#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/pr-template.sh"

echo "=== Checking Pull Request Template Usage ==="

main() {
    # PR Body can be passed as an environment variable or via file argument
    local pr_body="${PR_BODY:-}"
    local templates_dir="${TEMPLATES_DIR:-.github/PULL_REQUEST_TEMPLATE}"

    if [[ -z "$pr_body" && $# -gt 0 && -f "$1" ]]; then
        pr_body=$(cat "$1")
    fi

    validate_pr_body_not_empty "$pr_body"
    match_pr_template "$pr_body" "$templates_dir"
    validate_description_content "$pr_body"

    echo "✓ PR template check passed successfully."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
