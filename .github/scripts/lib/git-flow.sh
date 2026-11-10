GIT_FLOW_BASE_BRANCHES="main|master|develop|dev"
GIT_FLOW_PREFIX_TYPES="feature|bugfix|hotfix|release|support"

# Git Flow specification regex:
# <base-branch> | <prefix-type>/<name>
GIT_FLOW_REGEX="^(${GIT_FLOW_BASE_BRANCHES}|(${GIT_FLOW_PREFIX_TYPES})/[-a-zA-Z0-9_./]+)$"

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
        echo "  - ${GIT_FLOW_BASE_BRANCHES//|/ | }"
        local prefix
        for prefix in ${GIT_FLOW_PREFIX_TYPES//|/ }; do
            echo "  - ${prefix}/<${prefix}-name>"
        done
        return 1
    fi

    echo "✓ Branch name complies with Git Flow."
    return 0
}
