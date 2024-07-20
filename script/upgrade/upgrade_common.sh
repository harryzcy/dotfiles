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

  asdf update
  asdf plugin update --all

  # upgrade node
  node_latest=$(asdf latest nodejs)
  node_current=$(asdf current nodejs | awk '{print $2}')
  if [ "$node_latest" != "$node_current" ]; then
    echo "upgrading node"
    asdf install nodejs "$node_latest"
    asdf uninstall nodejs "$node_current"

    # reinstall global packages
    npm install -g "${node_packaegs[@]}"
  fi
}

upgrade_krex() {
  kubectl krew update
  kubectl krew upgrade
}
