GIT_FLOW_REGEX='^(main|master|develop|dev|(feature|bugfix|hotfix|release|support)/[-a-zA-Z0-9_./]+)$'

validate_branch_name() {
    local ref_name="$1"

    if [[ -z "$ref_name" ]]; then
        echo "::error::Branch name not provided."
        return 1
    fi

    echo "Checking branch: '$ref_name'"

    if [[ ! "$ref_name" =~ $GIT_FLOW_REGEX ]]; then
        echo "::error::Branch '$ref_name' violates Git Flow naming conventions."
        echo "Allowed branch names:"
        echo "  - main | master | develop | dev"
        echo "  - feature/<feature-name>"
        echo "  - bugfix/<bugfix-name>"
        echo "  - hotfix/<hotfix-name>"
        echo "  - release/<version>"
        echo "  - support/<support-name>"
        return 1
    fi

    echo "✓ Branch name complies with Git Flow."
    return 0
}
