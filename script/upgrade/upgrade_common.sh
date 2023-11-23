#!/usr/bin/env zsh

node_packaegs=(
  npm-check-updates
  serverless
  wrangler
  yarn
)

upgrade_zsh() {
  # upgrade oh-my-zsh
  if [ -z "$ZSH" ]; then
    ZSH="$HOME/.oh-my-zsh"
  fi
  ZSH="$ZSH" command zsh -f "$ZSH/tools/upgrade.sh" || return $?

  echo "updating zsh-autosuggestions"
  git -C $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull >/dev/null

  echo "updating zsh-syntax-highlighting"
  git -C $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting pull >/dev/null

}

upgrade_node() {
  source $DOTFILE_DIR/dev/.environments.zsh

  # upgrade nvm
  PROFILE=/dev/null # avoid nvm to modify .zshrc
  nvm_latest=$(curl -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
  nvm_latest=${nvm_latest##*/}
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_latest}/install.sh" | bash

  # upgrade node
  node_latest=$(nvm ls-remote | grep -i 'latest' | tail -n 1 | awk '{print $1}' | strings)
  node_current=$(nvm current)
  if [ "$node_latest" != "$node_current" ]; then
    echo "upgrading node"
    nvm install "$node_latest"
    nvm uninstall "$node_current"

    # reinstall global packages
    npm install -g "${node_packaegs[@]}"
  fi
}

upgrade_krex() {
  kubectl krew update
  kubectl krew upgrade
}
