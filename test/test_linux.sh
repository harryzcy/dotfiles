# tests for Raspberry Pi

check_tools() {
  # check_command dig
  # check_command nslookup

  if [[ "${IS_DEV_MACHINE}" = true ]]; then
    echo "Running tests for dev machines"
    check_command http
  fi
}

check_softwares() {
  # nothing
}
