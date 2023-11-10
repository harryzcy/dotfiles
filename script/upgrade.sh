#!/usr/bin/env zsh

set -o pipefail

# update oh-my-zsh
if [ -z "$ZSH" ]; then
  ZSH="$HOME/.oh-my-zsh"
fi
ZSH="$ZSH" command zsh -f "$ZSH/tools/upgrade.sh" || return $?

echo "updating zsh-autosuggestions"
git -C $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull >/dev/null

echo "updating zsh-syntax-highlighting"
git -C $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting pull >/dev/null

# update common tools
source $DOTFILE_DIR/shared/.functions.sh
os=$(detect_os)
if [[ "$os" == 'linux' ]]; then
  # linux
  source $DOTFILE_DIR/script/upgrade/upgrade_linux.sh
elif [[ "$os" == 'macos' ]]; then
  # macos
  source $DOTFILE_DIR/script/upgrade/upgrade_macos.sh
fi
