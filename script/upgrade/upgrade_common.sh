#!/usr/bin/env zsh

upgrade_zsh() {
  # upgrade oh-my-zsh
  if [ -z "$ZSH" ]; then
    ZSH="$HOME/.oh-my-zsh"
  fi
  ZSH="$ZSH" command zsh -f "$ZSH/tools/upgrade.sh" || return $?

  echo "updating zsh-autosuggestions"
  git -C $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull >/dev/null

  echo "updating zsh-syntax-highlighting"
  git -C $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting pull >/dev/null

}

upgrade_krex() {
  kubectl krew update
  kubectl krew upgrade
}
