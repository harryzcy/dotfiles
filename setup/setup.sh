#!/bin/bash

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

if [[ ${platform} == 'linux' ]]; then
  # platform specific src directory
  src_dir=${base_dir}/rpi

  source ./setup_linux.sh
  run_apt_update
elif [[ ${platform} == 'darwin' ]]; then
  # platform specific src directory
  src_dir=${base_dir}/darwin

  source ./setup_darwin.sh
  install_homebrew
else
  echo "unsupported platform: $platform"
  exit 1
fi

install_git
install_zsh ${src_dir}
