#!/bin/bash

# change to the directory of this script
current=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd ${current}

# detect the operating system
platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
  platform='darwin'
fi

if [[ ${platform} == 'linux' ]]; then
  source ./setup_linux.sh
elif [[ ${platform} == 'darwin' ]]; then
  source ./setup_darwin.sh

  # install homebrew
  install_homebrew
else
  echo "unsupported platform: $platform"
  exit 1
fi

# install zsh
install_zsh
