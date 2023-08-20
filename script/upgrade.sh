#!/usr/bin/env zsh

# update oh-my-zsh
if [ -z "$ZSH" ]; then
  ZSH="$HOME/.oh-my-zsh"
fi
ZSH="$ZSH" command zsh -f "$ZSH/tools/upgrade.sh" || return $?

# update common tools
echo "updating zsh-autosuggestions"
git -C $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull >/dev/null

echo "updating zsh-syntax-highlighting"
git -C $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting pull >/dev/null

# detect the operating system
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  # linux
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade
elif [[ "$unamestr" == 'Darwin' ]]; then
  # macos
  brew update && brew upgrade
  brew upgrade --cask

  # upgrade nvm
  nvm_latest=$(curl -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
  nvm_latest=${nvm_latest##*/}
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_latest}/install.sh" | bash
fi
