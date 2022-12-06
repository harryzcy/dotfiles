#!/usr/bin/env bash

install_xcode_select() {
  if ! xcode-select -p &> /dev/null
  then
    sudo xcode-select --install
  fi
}

install_homebrew() {
  if ! command -v brew &> /dev/null
  then
      echo "installing homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

run_brew_install() {
  package_name=$1
  executable_name=${2:-$package_name}

  if ! command -v brew &> /dev/null
  then
      echo "brew is not installed"
      exit 1
  fi

  if ! command -v $executable_name &> /dev/null
  then
      echo "installing $package_name"
      brew install $package_name
  fi
}

install_zsh() {
  if ! command -v zsh &> /dev/null
  then
    echo "installing zsh"
    brew install zsh
  fi
}

install_git() {
  if ! command -v git &> /dev/null
  then
    echo "installing git"
    brew install git
  fi
}

install_tools() {
  echo "installing tools for macOS"
  run_brew_install coreutils realpath
  run_brew_install cloc
  run_brew_install curl
  run_brew_install gh
  run_brew_install httpie
  run_brew_install jq
  run_brew_install python3
  run_brew_install tree
  run_brew_install wget
  run_brew_install gnupg gpg

  install_tools:node
}

install_tools:node() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
  [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
  nvm install --lts
  nvm use --lts
}

symlink_if_not_exists() {
  src="$1"
  dest="$DOTFILE_DIR/dot/bin/$2"

  if [ ! -f "$dest" ] && [ -f "$src"] ; then
    echo "symlinking \"$src\" to \"$dest\""
    ln -s "$src" "$dest"
  fi
}

create_bin() {
  if [ ! -d "$DOTFILE_DIR/dot/bin" ]
  then
    echo "creating $DOTFILE_DIR/dot/bin"
    mkdir $DOTFILE_DIR/dot/bin
  fi

  symlink_if_not_exists "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" chrome
}
