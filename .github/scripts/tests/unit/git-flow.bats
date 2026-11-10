setup() {
    load '../test_helper/common'
    source "${SCRIPTS_DIR}/lib/git-flow.sh"
}

@test "accepts valid git flow branch names" {
    local valid=(
        "main"
        "master"
        "develop"
        "dev"
        "feature/add-login"
        "feature/issue-123_test.refactor"
        "bugfix/fix-memory-leak"
        "hotfix/critical-patch"
        "release/v1.0.0"
        "release/1.2.3-rc1"
        "support/legacy-v0.1"
    )
    for branch in "${valid[@]}"; do
        run validate_branch_name "$branch"
        assert_success
        assert_output --partial "Branch name complies with Git Flow."
    done
}

@test "rejects branch names that don't follow git flow" {
    local invalid=(
        "my-feature"
        "feat/add-login"
        "fix/bug"
        "chore/cleanup"
        "feature"
        "bugfix"
        "hotfix"
        "release"
        "support"
        "feature/"
        "random/branch/name"
    )
    for branch in "${invalid[@]}"; do
        run validate_branch_name "$branch"
        assert_failure
        assert_output --partial "violates Git Flow naming conventions"
    done
}

@test "rejects empty branch name" {
    run validate_branch_name ""
    assert_failure
    assert_output --partial "Branch name not provided."
}
