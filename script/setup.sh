#!/usr/bin/env bash

# change to the directory of this script
current=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd ${current}

export DOTFILE_DIR=$(dirname ${current})

# detect the operating system
platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
  platform='macos'
fi

# detect architecture
arch=$(uname -m)
if [[ "$arch" == 'aar64' ]]; then
  arch='arm64'
fi

source ./setup/setup_common.sh

if [[ "${CODESPACES}" == 'true' ]]; then
  src_dir="${DOTFILE_DIR}/codespace"
  source ./setup/setup_linux.sh
elif [[ ${platform} == 'linux' ]]; then
  src_dir="${DOTFILE_DIR}/linux"
  source ./setup/setup_linux.sh
  if [[ "${NO_INSTALL}" != "true" ]]; then
    run_apt_update
  fi
elif [[ ${platform} == 'macos' ]]; then
  src_dir="${DOTFILE_DIR}/macos"
  source ./setup/setup_macos.sh
  install_xcode_select
  install_homebrew
  init_env
else
  echo "unsupported platform: $platform"
  exit 1
fi

[[ "${NO_INSTALL}" != "true" ]] && install_git
configure_git ${src_dir}
[[ "${NO_INSTALL}" != "true" ]] && install_zsh ${src_dir}
configure_zsh ${src_dir}

if [[ "${NO_INSTALL}" != "true" ]]; then
  install_tools

  if typeset -f install_software >/dev/null; then
    install_software
  fi
fi
