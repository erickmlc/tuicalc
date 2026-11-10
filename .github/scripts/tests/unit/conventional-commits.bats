setup() {
    load '../test_helper/common'
    source "${SCRIPTS_DIR}/lib/conventional-commits.sh"
}

@test "accepts valid topics" {
    while IFS= read -r subject || [[ -n "$subject" ]]; do
        [[ -z "$subject" ]] && continue
        run validate_message "$subject"
        assert_success
    done < "${FIXTURES_DIR}/valid_commit_subjects.txt"
}

@test "ignores merge commits" {
    while IFS= read -r subject || [[ -n "$subject" ]]; do
        [[ -z "$subject" ]] && continue
        run validate_message "$subject"
        assert_success
        assert_output --partial "Skipping merge commit"
    done < "${FIXTURES_DIR}/merge_commit_subjects.txt"
}

@test "rejects topics that don't fit the expected format." {
    while IFS= read -r subject || [[ -n "$subject" ]]; do
        [[ -z "$subject" ]] && continue
        run validate_message "$subject"
        assert_failure
        assert_output --partial "invalid format"
    done < "${FIXTURES_DIR}/invalid_commit_subjects.txt"
}

@test "reject empty subject" {
    run validate_message ""
    assert_failure
    assert_output --partial "empty subject"
}
