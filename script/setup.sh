#!/usr/bin/env bash

# change to the directory of this script
current=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd ${current}

base_dir=$(dirname ${current})

# detect the operating system
platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
  platform='darwin'
fi

source ./setup/setup_common.sh

if [[ ${CODESPACES} == 'true' ]]; then
  src_dir=${base_dir}/codespace
  source ./setup/setup_linux.sh
elif [[ ${platform} == 'linux' ]]; then
  # platform specific src directory
  src_dir=${base_dir}/rpi

  source ./setup/setup_linux.sh
  run_apt_update
elif [[ ${platform} == 'darwin' ]]; then
  # platform specific src directory
  src_dir=${base_dir}/darwin

  source ./setup/setup_darwin.sh
  install_xcode_select
  install_homebrew
else
  echo "unsupported platform: $platform"
  exit 1
fi

install_git
configure_git ${src_dir}
install_zsh ${src_dir}

configure_zsh ${src_dir}
install_tools
