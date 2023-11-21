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

# upgrade npm and node
nvm install --lts --latest-npm --reinstall-packages-from='lts/*'
