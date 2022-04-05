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

  # install oh-my-zsh
  if [[ ! -d $HOME/.oh-my-zsh ]]; then
    echo "installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi

  # init zshrc
  if [[ ! -f ~/.zshrc ]]; then
    echo "installing zshrc"
    ln -s ${src_dir}/.zshrc ~/.zshrc
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
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install git
  fi
}

install_tools() {

}
