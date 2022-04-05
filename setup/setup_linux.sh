#!/bin/bash

if ! command -v apt &> /dev/null
then
  echo "command apt could not be found"
  exit 1
fi

run_apt_update() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get update
}

install_zsh() {
  if ! command -v zsh &> /dev/null
  then
    echo "installing zsh"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install zsh
  fi
}

install_git() {
  if ! command -v git &> /dev/null
  then
    echo "installing git"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install git
  fi
}

install_tools() {
  echo "installing tools"
}
