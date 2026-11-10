setup() {
    load '../test_helper/common'
    use_stubs
}

# --- git stub ---

@test "git stub returns configured log output" {
    export STUB_GIT_LOG_OUTPUT="abc123	feat: add login"
    run git log
    assert_success
    assert_output "abc123	feat: add login"
}

@test "git stub returns configured exit code" {
    export STUB_GIT_EXIT_CODE=1
    run git log
    assert_failure
}

@test "git stub errors on unhandled subcommand" {
    run bash "${STUBS_DIR}/git" stash
    assert_failure
    assert_output --partial "unhandled subcommand 'stash'"
}

# --- gh stub ---

@test "gh stub returns configured output" {
    export STUB_GH_OUTPUT='{"number": 42}'
    run gh pr view
    assert_success
    assert_output '{"number": 42}'
}

# --- curl stub ---

@test "curl stub returns configured output" {
    export STUB_CURL_OUTPUT='{"status": "ok"}'
    run curl https://api.example.com
    assert_success
    assert_output '{"status": "ok"}'
}
