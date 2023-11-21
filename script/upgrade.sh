#!/usr/bin/env zsh

set -o pipefail

# common tools
source $DOTFILE_DIR/shared/.functions.sh
source $DOTFILE_DIR/shared/.environment.zsh
source $DOTFILE_DIR/script/upgrade/upgrade_common.sh

os=$(detect_os)
if [[ "$os" == 'linux' ]]; then
  # linux
  source $DOTFILE_DIR/script/upgrade/upgrade_linux.sh
elif [[ "$os" == 'macos' ]]; then
  # macos
  source $DOTFILE_DIR/script/upgrade/upgrade_macos.sh
fi
