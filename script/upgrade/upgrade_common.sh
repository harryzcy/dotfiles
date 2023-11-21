#!/usr/bin/env zsh

update_node() {
  source $DOTFILE_DIR/dev/.environments.zsh

  # upgrade nvm
  nvm_latest=$(curl -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
  nvm_latest=${nvm_latest##*/}
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_latest}/install.sh" | bash

  # upgrade node
  node_latest=$(nvm ls-remote | grep -i 'latest' | tail -n 1 | awk '{print $2}' | strings)
  node_current=$(nvm current)
  if [ "$node_latest" != "$node_current" ]; then
    echo "upgrading node"
    nvm install "$node_latest"
    nvm uninstall "$node_current"
  fi
}
