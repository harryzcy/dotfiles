#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR

set -o pipefail

# change to the directory of this script
current=$(cd -P -- "$(dirname -- "$0")" && pwd -P) || exit 1
cd "${current}" || exit 1

DOTFILE_DIR=$(dirname "${current}")
export DOTFILE_DIR
# shellcheck source=../shared/.functions.sh
source "${DOTFILE_DIR}/shared/.functions.sh"

os=$(detect_os) || exit 1
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
