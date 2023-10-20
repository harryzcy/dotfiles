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

source ./setup/util_common.sh

if [[ ${platform} == 'linux' ]]; then
  source ./setup/setup_linux.sh
elif [[ ${platform} == 'macos' ]]; then
  source ./setup/util_macos.sh
  source ./setup/setup_macos.sh
else
  echo "unsupported platform: $platform"
  exit 1
fi
