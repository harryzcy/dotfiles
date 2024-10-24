#!/usr/bin/env zsh

set -o pipefail

upgrade_brew() {
  brew update && brew upgrade
  brew upgrade --cask
}

### Main Script ###
upgrade_zsh
upgrade_brew
upgrade_krex
