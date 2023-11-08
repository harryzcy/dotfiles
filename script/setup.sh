#!/usr/bin/env bash

# change to the directory of this script
current=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd ${current}

export DOTFILE_DIR=$(dirname ${current})
source ${DOTFILE_DIR}/shared/.functions.sh

os=$(detect_os)
arch=$(detect_arch)

source ./common/util_common.sh

if [[ ${os} == 'linux' ]]; then
  source ./linux/setup_linux.sh
elif [[ ${os} == 'macos' ]]; then
  source ./macos/util_macos.sh
  source ./macos/setup_macos.sh
else
  echo "unsupported operating system: $os"
  exit 1
fi
