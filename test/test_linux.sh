#!/usr/bin/env zsh

check_tools() {
  # check_command dig
  # check_command nslookup

  if [[ "${IS_DEV_MACHINE}" = "true" ]]; then
    echo "Running tests for dev machines"
    check_command http
    check_command brew
    check_file "$HOME/.krew/bin/kubectl-krew"
    check_command asdf
    check_command gh
    check_command minisign
    check_command bazelisk
    check_command cosign
    check_command gpg
  fi
}

check_softwares() {
  # nothing
  true
}
