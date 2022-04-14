#!/bin/bash

# update oh-my-zsh
omz update

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
fi
