#!/bin/bash

install_homebrew() {
  if ! command -v brew &> /dev/null
  then
      echo "installing homebrew"
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

install_zsh() {
  if ! command -v zsh &> /dev/null
  then
    echo "installing zsh"
    brew install zsh
  fi
}