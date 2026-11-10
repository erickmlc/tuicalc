setup() {
    load '../test_helper/common'
}

@test "passes with valid branch name provided as argument" {
    run bash "${SCRIPTS_DIR}/validate-git-flow.sh" "feature/my-awesome-feature"
    assert_success
    assert_output --partial "=== Validating Git Flow Branch Naming ==="
    assert_output --partial "✓ Branch name complies with Git Flow."
}

@test "passes with valid branch name provided via GITHUB_REF_NAME env var" {
    GITHUB_REF_NAME="bugfix/fix-123" run bash "${SCRIPTS_DIR}/validate-git-flow.sh"
    assert_success
    assert_output --partial "✓ Branch name complies with Git Flow."
}

@test "fails when branch name violates git flow" {
    run bash "${SCRIPTS_DIR}/validate-git-flow.sh" "invalid-branch-name"
    assert_failure
    assert_output --partial "violates Git Flow naming conventions"
}

@test "fails when branch name is not provided" {
    run env -u GITHUB_REF_NAME bash "${SCRIPTS_DIR}/validate-git-flow.sh"
    assert_failure
    assert_output --partial "Branch name not provided."
}
