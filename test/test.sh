#!/usr/bin/env zsh

check_command() {
  if ! command -v $1 &> /dev/null
  then
    echo "command $1 could not be found"
    exit 1
  fi
}

check_file() {
  if [[ ! -f $1 ]]; then
    echo "file $1 could not be found"
    exit 1
  fi
}

check_directory() {
  if [[ ! -d $1 ]]; then
    echo "directory $1 could not be found"
    exit 1
  fi
}

check_sym_link() {
  if [[ ! -L $1 ]]; then
    echo "symbolic link $1 could not be found"
    exit 1
  fi
  if [[ ! -e $1 ]]; then
    echo "symbolic link $1 is broken"
    exit 1
  fi
}

# git
check_command git
check_sym_link $HOME/.gitconfig
check_sym_link $HOME/.gitignore_global

# zsh
check_command zsh
check_sym_link $HOME/.zshrc
check_directory $HOME/.oh-my-zsh
