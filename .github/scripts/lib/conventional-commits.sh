CONVENTIONAL_COMMITS_TYPES="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"
# Conventional Commits specification regex:
# <type>(<scope>)?: <subject>
CONVENTIONAL_REGEX="^(${CONVENTIONAL_COMMITS_TYPES})(\([-a-zA-Z0-9_./]+\))?(!)?: .+$"

validate_message() {
    local subject="$1"

    if [[ -z "$subject" ]]; then
        echo "::error::Commit message is empty: empty subject"
        return 1
    fi

    # Ignore merge commits
    if [[ "$subject" =~ ^Merge[[:space:]] ]]; then
        echo "✓ Skipping merge commit: '$subject'"
        return 0
    fi

    if [[ ! "$subject" =~ $CONVENTIONAL_REGEX ]]; then
        echo "::error::Commit message [${subject}] does not conform to Conventional Commits: invalid format"
        echo "  Expected format: '<type>(<optional-scope>): <description>'"
        echo "  Allowed types: ${CONVENTIONAL_COMMITS_TYPES//|/, }"
        return 1
    else
        echo "✓ Commit message [${subject}] is valid: '$subject'"
        return 0
    fi
}
