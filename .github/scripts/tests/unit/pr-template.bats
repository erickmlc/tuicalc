setup() {
    load '../test_helper/common'
    use_stubs
    source "${SCRIPTS_DIR}/lib/pr-template.sh"
    TEMPLATES_REAL_DIR="${SCRIPTS_DIR}/../PULL_REQUEST_TEMPLATE"
}

@test "validate_pr_body_not_empty accepts non-empty body" {
    run validate_pr_body_not_empty "Some PR text"
    assert_success
}

@test "validate_pr_body_not_empty rejects empty or whitespace-only body" {
    run validate_pr_body_not_empty ""
    assert_failure
    assert_output --partial "PR description is completely empty"

    run validate_pr_body_not_empty "   "$'\n\t'
    assert_failure
    assert_output --partial "PR description is completely empty"
}

@test "validate_description_content accepts non-empty description content" {
    local body
    body="$(cat "${FIXTURES_DIR}/pr_description_valid.md")"
    run validate_description_content "$body"
    assert_success
}

@test "validate_description_content rejects description with only html comments or whitespace" {
    local body
    body="$(cat "${FIXTURES_DIR}/pr_description_placeholder_only.md")"
    run validate_description_content "$body"
    assert_failure
    assert_output --partial "The 'Description' section is empty or contains only comments/placeholders"
}

@test "validate_description_content rejects body without description header" {
    local body
    body="$(cat "${FIXTURES_DIR}/pr_description_no_header.md")"
    run validate_description_content "$body"
    assert_failure
    assert_output --partial "The 'Description' section is empty or contains only comments/placeholders"
}

@test "extract_template_required_headers extracts mandatory headers and ignores optional sections" {
    local test_template="${FIXTURES_DIR}/sample_template.md"

    run extract_template_required_headers "$test_template"
    assert_success
    assert_output --partial "## Description"
    assert_output --partial "## Related Issue"
    assert_output --partial "## Checklist"
    refute_output --partial "if applicable"
    refute_output --partial "Additional Notes"
}

@test "match_pr_template matches standard templates" {
    local pull_request_template_body
    pull_request_template_body="$(cat "${FIXTURES_DIR}/pr_match_valid_body.md")"

    run match_pr_template "$pull_request_template_body" "$TEMPLATES_REAL_DIR"
    assert_success
    assert_output --partial "Successfully validated PR body against template: pull_request_template.md"
}

@test "match_pr_template fails when required sections are missing" {
    local incomplete_body
    incomplete_body="$(cat "${FIXTURES_DIR}/pr_match_incomplete_body.md")"

    run match_pr_template "$incomplete_body" "$TEMPLATES_REAL_DIR"
    assert_failure
    assert_output --partial "PR body does not follow any expected PR template format"
}

@test "match_pr_template fails if templates directory does not exist" {
    run match_pr_template "some body" "/non/existent/path"
    assert_failure
    assert_output --partial "Templates directory '/non/existent/path' does not exist."
}
