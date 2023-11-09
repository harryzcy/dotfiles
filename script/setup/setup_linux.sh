#!/usr/bin/env bash

set -o pipefail

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

  (
    set -x
    cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
  )
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
configure_zsh ${src_dir}
