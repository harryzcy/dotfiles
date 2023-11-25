#!/usr/bin/env zsh

check_git() {
  check_command git
  check_file "$HOME/.gitconfig"
  check_file "$HOME/.gitignore_global"
}

check_zsh() {
  check_command zsh
  check_sym_link "$HOME/.zshrc"
  check_directory "$HOME/.oh-my-zsh"
}
