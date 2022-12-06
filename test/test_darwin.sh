# tests for macOS

check_tools() {
  check_command cloc
  check_command curl
  check_command gh
  check_command httpie
  check_command jq
  check_command python3
  check_command tree
  check_command wget
  check_command gpg # gnupg from brew
}

check_softwares() {
  check_directory "/Applications/Google Chrome.app"
  check_directory "/Applications/Visual Studio Code.app"
}
