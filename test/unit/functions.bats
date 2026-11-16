#!/usr/bin/env bats

setup() {
  DOTFILE_DIR=$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)
  export DOTFILE_DIR
  # shellcheck source=../../shared/.functions.sh
  source "${DOTFILE_DIR}/shared/.functions.sh"
}

@test "shared functions load" {
  declare -F version_gt
}
