#!/usr/bin/env bash

set -o pipefail

if ! command -v apt &>/dev/null; then
  echo "command apt could not be found"
  exit 1
fi

run_apt_update() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update
}

run_apt_install() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install "$@"
}

install_tools() {
  echo "installing tools"
  run_apt_install git
  run_apt_install zsh
}

install_tools:asdf() {
  if ! command -v asdf &>/dev/null; then
    install_asdf "$(asdf_latest_version)"
  fi
}

install_tools:node() {
  install_tools:asdf
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

  asdf install nodejs latest
  asdf set --home nodejs latest
}

install_tools:python() {
  install_tools:uv
  uv tool install ansible-lint
  uv tool install ansible
  uv tool install httpie
  uv tool install hashin
  uv tool install pip-tools
}

install_tools:terraform() {
  install_tools:asdf
  asdf plugin add terraform https://github.com/asdf-community/asdf-hashicorp.git

  asdf install terraform latest
  asdf set --home terraform latest
}

install_tools:opentofu() {
  install_tools:asdf
  asdf plugin add opentofu https://github.com/virtualroot/asdf-opentofu.git

  asdf install opentofu latest
  asdf set --home opentofu latest
}

install_tools:gh() {
  # gh in the apt archive is frozen at the ubuntu release version,
  # so install from GitHub releases instead
  install_gh "$(gh_latest_version)"
}

install_tools:dev() {
  # later steps use tools installed to dot/bin, e.g. the opentofu plugin looks for cosign
  export PATH="$DOTFILE_DIR/dot/bin:$PATH"
  install_krew
  run_apt_install cloc
  run_apt_install jq
  run_apt_install minisign
  run_apt_install gnupg
  install_tools:gh
  install_bazelisk
  install_cosign "$(cosign_latest_version)"
  install_tools:node
  install_tools:python
  install_tools:bun
  install_tools:terraform
  install_tools:opentofu
}

if [[ "${CODESPACES}" == 'true' ]]; then
  src_dir="${DOTFILE_DIR}/codespace"
else
  src_dir="${DOTFILE_DIR}/linux"
fi

source "${DOTFILE_DIR}/shared/.environments.sh"
if [[ "${NO_INSTALL}" != "true" ]]; then
  run_apt_update
  install_tools

  if [[ "${IS_DEV_MACHINE}" = true ]]; then
    install_tools:dev
  fi
fi
configure_git "${src_dir}"
configure_zsh "${src_dir}"
