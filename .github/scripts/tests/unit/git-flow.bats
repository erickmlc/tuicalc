setup() {
    load '../test_helper/common'
    use_stubs
    source "${SCRIPTS_DIR}/lib/git-flow.sh"
}

@test "accepts valid git flow branch names" {
    while IFS= read -r branch || [[ -n "$branch" ]]; do
        [[ -z "$branch" ]] && continue
        run validate_branch_name "$branch"
        assert_success
        assert_output --partial "Branch name complies with Git Flow."
    done < "${FIXTURES_DIR}/valid_branch_names.txt"
}

@test "rejects branch names that don't follow git flow" {
    while IFS= read -r branch || [[ -n "$branch" ]]; do
        [[ -z "$branch" ]] && continue
        run validate_branch_name "$branch"
        assert_failure
        assert_output --partial "violates Git Flow naming conventions"
    done < "${FIXTURES_DIR}/invalid_branch_names.txt"
}

@test "rejects empty branch name" {
    run validate_branch_name ""
    assert_failure
    assert_output --partial "Branch name not provided."
}
