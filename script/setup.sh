#!/usr/bin/env bash

# change to the directory of this script
current=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd ${current}

export DOTFILE_DIR=$(dirname ${current})
source ${DOTFILE_DIR}/shared/.functions.sh

os=$(detect_os)
arch=$(detect_arch)

source ./setup/util_common.sh

if [[ ${os} == 'linux' ]]; then
  source ./setup/setup_linux.sh
elif [[ ${os} == 'macos' ]]; then
  source ./setup/util_macos.sh
  source ./setup/setup_macos.sh
else
  echo "unsupported operating system: $os"
  exit 1
fi
