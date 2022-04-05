#!/bin/bash

unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  # linux
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq autoremove
elif [[ "$unamestr" == 'Darwin' ]]; then
  # macos
  brew cleanup -s
fi
