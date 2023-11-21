#!/usr/bin/env zsh

set -o pipefail

upgrade_brew() {
  brew update && brew upgrade
  brew upgrade --cask
}

upgrade_brew
upgrade_krex
upgrade_node
