setup() {
    load '../test_helper/common'

    cd "$BATS_TEST_TMPDIR"
    git init -q -b main
    git config user.email "test@test.com"
    git config user.name "test"
    git commit -q --allow-empty -m "chore: init"
    git checkout -q -b feature
}

@test "passes when all commits in the PR are valid" {
    git commit -q --allow-empty -m "feat: add feature"
    git commit -q --allow-empty -m "fix(feature): fix bug"

    run bash "${SCRIPTS_DIR}/check-conventional-commits.sh" main HEAD
    assert_success
}

@test "fail and list all invalid commits" {
    git commit -q --allow-empty -m "feat: add feature"
    git commit -q --allow-empty -m "various fixes"
    git commit -q --allow-empty -m "WIP"

    run bash "${SCRIPTS_DIR}/check-conventional-commits.sh" main HEAD
    assert_failure
    assert_output --partial "[various fixes]"
    assert_output --partial "[WIP]"
    refute_output --partial "::error::Commit message [feat: add feature]"
}

@test "passes when there are no new commits" {
    run bash "${SCRIPTS_DIR}/check-conventional-commits.sh" main HEAD
    assert_success
}

@test "ignores merge commits" {
    git commit -q --allow-empty -m "feat: add login"
    git checkout -q main
    git commit -q --allow-empty -m "chore: something on main"
    git checkout -q feature
    git merge -q --no-ff main -m "Merge branch 'main' into feature"

    run bash "${SCRIPTS_DIR}/check-conventional-commits.sh" main HEAD
    assert_success
}

@test "fails without base ref argument" {
    run bash "${SCRIPTS_DIR}/check-conventional-commits.sh"
    assert_failure
    assert_output --partial "base ref required"
}
