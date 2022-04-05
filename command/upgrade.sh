#!/bin/bash

# detect the operating system
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  # linux
  sudo DEBIAN_FRONTEND=noninteractive apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade
elif [[ "$unamestr" == 'Darwin' ]]; then
  # macos
  brew update && brew upgrade
  brew upgrade --cask
fi
