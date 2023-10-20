#!/usr/bin/env bash

if ! command -v apt &>/dev/null; then
  echo "command apt could not be found"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

run_apt_update() {
  sudo apt-get -yq update
}

install_tools() {
  echo "installing tools"
  sudo apt-get -yq install git
  sudo apt-get -yq install zsh
}

if [[ "${CODESPACES}" == 'true' ]]; then
  src_dir="${DOTFILE_DIR}/codespace"
else
  src_dir="${DOTFILE_DIR}/linux"
fi

if [[ "${NO_INSTALL}" != "true" ]]; then
  run_apt_update
  install_tools
fi
configure_git ${src_dir}
