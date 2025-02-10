#!/usr/bin/env zsh

check_tools() {
  # check_command dig
  # check_command nslookup

  if [[ "${IS_DEV_MACHINE}" = "true" ]]; then
    echo "Running tests for dev machines"
    check_command http
    check_command brew
    check_command asdf
  fi
}

check_softwares() {
  # nothing
  true
}
