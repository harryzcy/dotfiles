#!/usr/bin/env bash
# setup functions common to all platforms

create_symlink() {
  src="$1"
  dest="$2"

  current_dest=$(readlink "$dest")
  if [ "$current_dest" != "$src" ]; then
    echo "symlinking \"$src\" to \"$dest\""
    ln -sf "$src" "$dest"
  fi
}

# clone oh-my-zsh like its install.sh, without the rest of the setup
install_ohmyzsh() {
  (
    # no group or other write, so compinit doesn't warn
    umask g-w,o-w
    git clone --quiet --depth=1 --branch master \
      -c core.eol=lf \
      -c core.autocrlf=false \
      -c fsck.zeroPaddedFilemode=ignore \
      -c fetch.fsck.zeroPaddedFilemode=ignore \
      -c receive.fsck.zeroPaddedFilemode=ignore \
      -c oh-my-zsh.remote=origin \
      -c oh-my-zsh.branch=master \
      https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  )
}

configure_zsh() {
  src_dir=$1

  # Set ZSH as the default shell
  # Skip this when running in GitHub Codespace, it's configured via setting
  if [ "$(basename "${SHELL}")" != "zsh" ] && [ "${CODESPACES}" != "true" ]; then
    chsh -s "$(command -v zsh)"
  fi

  # install oh-my-zsh
  if [[ ! -d $HOME/.oh-my-zsh ]]; then
    echo "installing oh-my-zsh"
    install_ohmyzsh
  fi

  # init zshrc
  if [[ -e $HOME/.zshrc || -L $HOME/.zshrc ]]; then
    echo "backup $HOME/.zshrc to $HOME/.zshrc.bak"
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi
  create_symlink "${src_dir}/.zshrc" "$HOME/.zshrc"

  # install plugins
  if [[ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
    echo "installing zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  fi

  if [[ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
    echo "installing zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  fi
}

configure_git() {
  src_dir=$1

  if [[ ! -f $HOME/.gitconfig ]]; then
    echo "creating .gitconfig"
    cp "${src_dir}/git/.gitconfig" "$HOME/.gitconfig"
  fi

  if [[ ! -f $HOME/.gitignore_global ]]; then
    echo "creating .gitignore_global"
    cp "${src_dir}/git/.gitignore_global" "$HOME/.gitignore_global"
  fi
}

install_tools:bun() {
  BUN_INSTALL="$HOME/.bun"
  if [ -d "$BUN_INSTALL" ]; then
    echo "bun is already installed"
  else
    echo "installing bun"
    install_bun "$(bun_latest_version)"
  fi
}

install_tools:uv() {
  if ! command -v uv &>/dev/null; then
    install_uv "$(uv_latest_version)" || return 1
    export PATH="$HOME/.local/bin:$PATH"
    uv python install
  fi
}
