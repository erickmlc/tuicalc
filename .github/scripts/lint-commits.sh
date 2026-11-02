#!/usr/bin/env bash
set -euo pipefail

echo "=== Checking Conventional Commits (Native Bash) ==="

BEFORE_COMMIT="${BEFORE_COMMIT:-}"
AFTER_COMMIT="${AFTER_COMMIT:-}"

# Conventional Commits specification regex:
# <type>(<scope>)?: <subject>
# Allowed types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
CONVENTIONAL_REGEX="^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([-a-zA-Z0-9_./]+\))?(!)?: .+$"

FAILED=0

validate_message() {
    local sha="$1"
    local subject="$2"

    # Ignore merge commits
    if [[ "$subject" =~ ^Merge[[:space:]] ]]; then
        echo "✓ Skipping merge commit [${sha:0:7}]: '$subject'"
        return 0
    fi

    if [[ ! "$subject" =~ $CONVENTIONAL_REGEX ]]; then
        echo "::error::Commit [${sha:0:7}] does not conform to Conventional Commits: '$subject'"
        echo "  Expected format: '<type>(<optional-scope>): <description>'"
        echo "  Allowed types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert"
        FAILED=1
    else
        echo "✓ Commit [${sha:0:7}] is valid: '$subject'"
    fi
}

# Determine commit range
if [[ -z "$BEFORE_COMMIT" || "$BEFORE_COMMIT" =~ ^0+$ ]]; then
    echo "New branch or initial push detected. Validating the latest commit..."
    COMMIT_LIST=$(git log -1 --format="%H%x09%s")
else
    echo "Validating commits between ${BEFORE_COMMIT:0:7} and ${AFTER_COMMIT:0:7}..."
    COMMIT_LIST=$(git log --no-merges --format="%H%x09%s" "${BEFORE_COMMIT}..${AFTER_COMMIT}")
fi

if [[ -z "$COMMIT_LIST" ]]; then
    echo "No commits found to inspect."
    exit 0
fi

while IFS=$'\t' read -r sha subject; do
    [[ -z "$sha" ]] && continue
    validate_message "$sha" "$subject"
done <<< "$COMMIT_LIST"

if [[ "$FAILED" -ne 0 ]]; then
    echo "::error::One or more commits failed the Conventional Commits check."
    exit 1
fi

echo "All commits comply with Conventional Commits."
