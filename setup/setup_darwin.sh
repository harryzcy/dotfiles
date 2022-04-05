#!/bin/bash

# this_file=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
# base_dir=$(dirname ${this_file})
# echo ${this_file}


install_homebrew() {
  if ! command -v brew &> /dev/null
  then
      echo "installing homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
  if [[ -z ${ZSH} || ! -d ${ZSH} ]]; then
    echo "installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi

  # init zshrc
  if [[ ! -f ~/.zshrc ]]; then
    echo "installing zshrc"
    ln -s ${src_dir}/.zshrc ~/.zshrc
  fi

  # install plugins
  if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
    echo "installing zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  else
    echo "updating zsh-autosuggestions"
    pushd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions > /dev/null
    git pull > /dev/null
    popd > /dev/null
  fi
}

install_git() {
  if ! command -v git &> /dev/null
  then
    echo "installing git"
    brew install git
  fi
}
