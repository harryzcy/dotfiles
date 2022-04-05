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

check_command git
check_command zsh
check_file $HOME/.zshrc
check_directory $HOME/.oh-my-zsh
