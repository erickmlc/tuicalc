setup() {
    load '../test_helper/common'
    use_stubs
}

@test "passes when all commits are valid" {
    export STUB_GIT_LOG_OUTPUT=$'abc123\tfeat: add login\ndef456\tfix: typo'

    run bash "${SCRIPTS_DIR}/check-conventional-commits.sh" main HEAD
    assert_success
    assert_output --partial "✓ All commits comply with Conventional Commits."
}

@test "fails and lists invalid commits" {
    export STUB_GIT_LOG_OUTPUT=$'abc123\tfeat: add login\ndef456\tvarious fixes'

    run bash "${SCRIPTS_DIR}/check-conventional-commits.sh" main HEAD
    assert_failure
    assert_output --partial "[various fixes]"
    refute_output --partial "::error::Commit message [feat: add login]"
}

@test "passes when there are no commits to inspect" {
    run bash "${SCRIPTS_DIR}/check-conventional-commits.sh" main HEAD
    assert_success
    assert_output --partial "No commits found to inspect."
}

@test "uses BEFORE_COMMIT and AFTER_COMMIT range" {
    export STUB_GIT_LOG_OUTPUT=$'abc123\tfeat: add login'

    BEFORE_COMMIT=aaaaaaa AFTER_COMMIT=bbbbbbb \
        run bash "${SCRIPTS_DIR}/check-conventional-commits.sh"
    assert_success
    assert_output --partial "Validating commits between aaaaaaa and bbbbbbb..."
}

@test "validates the latest commit for an initial push" {
    export STUB_GIT_LOG_OUTPUT=$'abc123\tfeat: add login'

    BEFORE_COMMIT=0000000 AFTER_COMMIT=abc1234 \
        run bash "${SCRIPTS_DIR}/check-conventional-commits.sh"
    assert_success
    assert_output --partial "New branch or initial push detected."
}
