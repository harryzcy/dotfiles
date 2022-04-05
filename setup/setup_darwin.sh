#!/bin/bash


install_homebrew() {
  if ! command -v brew &> /dev/null
  then
      echo "installing homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

run_brew_install() {
  package_name=$1
  exxecutable_name=${2:-$package_name}

  if ! command -v brew &> /dev/null
  then
      echo "brew is not installed"
      exit 1
  fi
  if ! command -v $2 &> /dev/null
  then
      echo "installing $1"
      brew install $1
  fi
}

install_zsh() {
  src_dir=$1

  if ! command -v zsh &> /dev/null
  then
    echo "installing zsh"
    brew install zsh
  fi

  # install oh-my-zsh
  if [[ ! -d $HOME/.oh-my-zsh ]]; then
    echo "installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi

  # init zshrc
  if [[ -f $HOME/.zshrc ]]; then
    if [[ ! -L $HOME/.zshrc ]]; then
      echo "backup $HOME/.zshrc to $HOME/.zshrc.bak"
      mv $HOME/.zshrc $HOME/.zshrc.bak

      echo "creating symlink for .zshrc"
      ln -s ${src_dir}/.zshrc $HOME/.zshrc
    fi
  else
    echo "creating symlink for .zshrc"
    ln -s ${src_dir}/.zshrc $HOME/.zshrc
  fi

  # install plugins
  if [[ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
    echo "installing zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  else
    echo "updating zsh-autosuggestions"
    pushd $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions > /dev/null
    git pull > /dev/null
    popd > /dev/null
  fi

  if [[ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
    echo "installing zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
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
  run_brew_install tree
  run_brew_install wget
  run_brew_install curl
  run_brew_install jq
}
