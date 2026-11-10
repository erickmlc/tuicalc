load "${BATS_TEST_DIRNAME}/../test_helper/bats-support/load"
load "${BATS_TEST_DIRNAME}/../test_helper/bats-assert/load"

SCRIPTS_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
FIXTURES_DIR="${SCRIPTS_DIR}/tests/fixtures"
STUBS_DIR="${SCRIPTS_DIR}/tests/stubs"

setup_github_env() {
    export GITHUB_OUTPUT="${BATS_TEST_TMPDIR}/github_output"
    export GITHUB_EVENT_PATH="${FIXTURES_DIR}/github_event_pr.json"
    : > "$GITHUB_OUTPUT"
}

use_stubs() {
    local stub_dir="$STUBS_DIR"

    # Some filesystems (e.g. vfat) cannot store the executable bit. Fall back
    # to executable wrappers in a temporary directory when the stubs are not
    # directly executable.
    if [[ ! -x "${STUBS_DIR}/git" ]]; then
        stub_dir="${BATS_TEST_TMPDIR:-${TMPDIR:-/tmp}}/stubs-bin"
        mkdir -p "$stub_dir"

        local stub name
        for stub in "${STUBS_DIR}"/*; do
            [[ -f "$stub" ]] || continue
            name="$(basename "$stub")"
            printf '#!/usr/bin/env bash\nexec bash %q "$@"\n' "$stub" > "${stub_dir}/${name}"
            chmod +x "${stub_dir}/${name}"
        done
    fi

    export PATH="${stub_dir}:${PATH}"
}