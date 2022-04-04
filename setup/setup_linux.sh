#!/bin/bash

if ! command -v apt &> /dev/null
then
  echo "command apt could not be found"
  exit 1
fi

install_zsh() {
  if ! command -v zsh &> /dev/null
  then
    echo "installing zsh"
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install zsh
  fi
}
