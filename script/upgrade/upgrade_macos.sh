#!/usr/bin/env zsh

set -o pipefail

brew update && brew upgrade
brew upgrade --cask

# krew
kubectl krew update
kubectl krew upgrade

update_node
