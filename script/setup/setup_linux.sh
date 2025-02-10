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

  install_homebrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

install_tools:node() {
  if [[ ! -d "$HOME/.asdf" ]]; then
    brew install asdf
  fi

  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

  asdf install nodejs latest
  asdf set --home nodejs latest
}

install_tools:dev() {
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

  run_apt_install cloc
  run_apt_install jq
  install_tools:node

  if ! command -v pipx &>/dev/null; then
    echo "installing pipx"
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
  fi
  pipx install httpie
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
