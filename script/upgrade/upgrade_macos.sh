#!/usr/bin/env zsh

set -o pipefail

brew update && brew upgrade
brew upgrade --cask

# krew
kubectl krew update
kubectl krew upgrade

# upgrade nvm
nvm_latest=$(curl -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
nvm_latest=${nvm_latest##*/}
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_latest}/install.sh" | bash

# upgrade node
node_latest=$(nvm ls-remote | grep -i 'latest' | tail -n 1 | awk '{print $2}')
node_current=$(nvm current)
if [[ "$node_latest" != "$node_current" ]]; then
  echo "upgrading node"
  nvm install lts
  nvm uninstall "$node_current"
fi
