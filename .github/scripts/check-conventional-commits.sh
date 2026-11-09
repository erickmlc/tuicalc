#!/usr/bin/env bash
# check-conventional-commits.sh <base-ref> [head-ref]
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib/conventional-commits.sh"

echo "=== Checking Conventional Commits ==="

AFTER_COMMIT="${AFTER_COMMIT:-}"
BEFORE_COMMIT="${BEFORE_COMMIT:-}"

main () {
    local base_ref="${1:-}"
    local head_ref="${2:-HEAD}"
    local commits subject failed=0

    if [[ -n "$base_ref" ]]; then
        commits=$(git log --no-merges --format="%H%x09%s" "${base_ref}..${head_ref}")
    elif [[ -n "${BEFORE_COMMIT:-}" && ! "$BEFORE_COMMIT" =~ ^0+$ ]]; then
        echo "Validating commits between ${BEFORE_COMMIT:0:7} and ${AFTER_COMMIT:0:7}..."
        commits=$(git log --no-merges --format="%H%x09%s" "${BEFORE_COMMIT}..${AFTER_COMMIT}")
    elif [[ -n "${BEFORE_COMMIT:-}" && "$BEFORE_COMMIT" =~ ^0+$ ]]; then
        echo "New branch or initial push detected. Validating the latest commit..."
        commits=$(git log -1 --format="%H%x09%s")
    else
        echo "::error::base ref required"
        exit 1
    fi

    if [[ -z "$commits" ]]; then
        echo "No commits found to inspect."
        exit 0
    fi

    while IFS=$'\t' read -r sha subject; do
        [[ -z "$sha" ]] && continue
        validate_message "$subject" || failed=1
    done <<< "$commits"

    if [[ "$failed" -ne 0 ]]; then
        echo "::error::One or more commits failed the Conventional Commits check."
        exit 1
    fi

    echo "✓ All commits comply with Conventional Commits."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
