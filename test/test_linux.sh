#!/usr/bin/env zsh

check_tools() {
  # check_command dig
  # check_command nslookup

  if [[ "${IS_DEV_MACHINE}" = "true" ]]; then
    echo "Running tests for dev machines"
    export PATH="/home/linuxbrew/.linuxbrew/bin:$HOME/.asdf/shims:$PATH"
    check_command http
    check_command brew
    check_command asdf
  fi
}

check_softwares() {
  # nothing
  true
}
