#!/usr/bin/env zsh

brew update && brew upgrade
brew upgrade --cask

# krew
kubectl krew update
kubectl krew upgrade

# upgrade nvm
nvm_latest=$(curl -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
nvm_latest=${nvm_latest##*/}
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_latest}/install.sh" | bash