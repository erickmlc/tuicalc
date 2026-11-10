setup() {
    load '../test_helper/common'
    use_stubs
    VALID_PR_FILE="${FIXTURES_DIR}/valid_pr.md"
    INVALID_PR_FILE="${FIXTURES_DIR}/invalid_pr.md"
}

@test "passes with valid PR body passed via file argument" {
    run bash "${SCRIPTS_DIR}/validate-pr-template.sh" "$VALID_PR_FILE"
    assert_success
    assert_output --partial "=== Checking Pull Request Template Usage ==="
    assert_output --partial "✓ Successfully validated PR body against template: pull_request_template.md"
    assert_output --partial "✓ PR template check passed successfully."
}

@test "passes with valid PR body passed via PR_BODY environment variable" {
    PR_BODY=$(cat "$VALID_PR_FILE") run bash "${SCRIPTS_DIR}/validate-pr-template.sh"
    assert_success
    assert_output --partial "✓ PR template check passed successfully."
}

@test "fails when PR body is completely empty" {
    run env -u PR_BODY bash "${SCRIPTS_DIR}/validate-pr-template.sh"
    assert_failure
    assert_output --partial "PR description is completely empty"
}

@test "fails when PR body does not match any template" {
    local random_file="${BATS_TEST_TMPDIR}/random.md"
    echo "Just some random text without headers" > "$random_file"

    run bash "${SCRIPTS_DIR}/validate-pr-template.sh" "$random_file"
    assert_failure
    assert_output --partial "PR body does not follow any expected PR template format"
}

@test "fails when Description contains only placeholders or comments" {
    run bash "${SCRIPTS_DIR}/validate-pr-template.sh" "$INVALID_PR_FILE"
    assert_failure
    assert_output --partial "The 'Description' section is empty or contains only comments/placeholders."
}
