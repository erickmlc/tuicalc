setup() {
    load '../test_helper/common'
    source "${SCRIPTS_DIR}/lib/conventional-commits.sh"
}

@test "accepts valid topics" {
    local valid=(
        "feat: add feature"
        "fix(something): fixes something"
        "feat!: remove feature"
        "refactor(.github/tests): refactor CI tests"
        "chore(deps): update dependencies"
  )
    for subject in "${valid[@]}"; do
        run validate_message "$subject"
        assert_success
    done
}

@test "ignores merge commits" {
    local merges=(
        "Merge branch 'develop'"
        "Merge pull request #42 from repo/branch"
        "Merge remote-tracking branch 'origin/main'"
    )
    for subject in "${merges[@]}"; do
        run validate_message "$subject"
        assert_success
        assert_output --partial "Skipping merge commit"
    done
}

@test "rejects topics that don't fit the expected format." {
    local invalid=(
        "add feature"               # without type
        "feature: add feature"      # unknown type
        "feat add feature"          # without two points
        "feat:add feature"          # no space after ':'
        "feat(): add feature"       # empty scope
        "Feat: add feature"         # type in uppercase
        "feat: "                    # without description
  )
    for subject in "${invalid[@]}"; do
        run validate_message "$subject"
        assert_failure
        assert_output --partial "invalid format"
    done
}

@test "reject empty subject" {
    run validate_message ""
    assert_failure
    assert_output --partial "empty subject"
}
