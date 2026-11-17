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

# upgrade_release <name> <current version> [install args...]
# installs the latest release with install_<name> when <name>_latest_version is newer
upgrade_release() {
  local name=$1 current_version=$2 latest_version
  shift 2
  latest_version=$("${name}_latest_version") || return 1
  if version_gt "$latest_version" "$current_version"; then
    echo "upgrading ${name//_/-}"
    "install_${name}" "$latest_version" "$@"
  fi
}

upgrade_bun() {
  if ! command -v bun &>/dev/null; then
    echo "bun is not installed, skipping upgrade"
    return
  fi
  upgrade_release bun "$(bun --version 2>/dev/null)"
}
