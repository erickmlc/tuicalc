setup() {
    load '../test_helper/common'
    VALID_PR_FILE="${BATS_TEST_TMPDIR}/valid_pr.md"
    INVALID_PR_FILE="${BATS_TEST_TMPDIR}/invalid_pr.md"

    cat << 'EOF' > "$VALID_PR_FILE"
## Description

Implemented branch validation and PR template unit and integration tests.

## Related Issue

Closes #42

## Change Type

- [x] Refactoring

## How to Test

Run bats tests in .github/scripts/tests.

## Checklist

- [x] Tests added
- [x] All tests passing
EOF

    cat << 'EOF' > "$INVALID_PR_FILE"
## Description

<!-- placeholder only -->

## Related Issue

Closes #42

## Change Type

- [x] Refactoring

## How to Test

Run bats tests in .github/scripts/tests.

## Checklist

- [x] Tests added
- [x] All tests passing
EOF
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
