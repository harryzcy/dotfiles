#!/bin/bash

install_homebrew() {
  if ! command -v brew &> /dev/null
  then
      echo "installing homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

install_zsh() {
  if ! command -v zsh &> /dev/null
  then
    echo "installing zsh"
    brew install zsh
  fi

  # install oh-my-zsh
  if [ ! -d ~/.oh-my-zsh ]; then
    echo "installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi
}

install_git() {
  if ! command -v git &> /dev/null
  then
    echo "installing git"
    brew install git
  fi
}
