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
  export PATH="${STUBS_DIR}:${PATH}"
}