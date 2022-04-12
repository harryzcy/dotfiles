# common tests

check_git() {
  # git
  check_command git
  check_sym_link $HOME/.gitconfig
  check_sym_link $HOME/.gitignore_global
}

check_zsh() {
  # zsh
  check_command zsh
  check_sym_link $HOME/.zshrc
  check_directory $HOME/.oh-my-zsh
}
