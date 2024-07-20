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

configure_zsh() {
  src_dir=$1

  # Set ZSH as the default shell
  # Skip this when running in GitHub Codespace, it's configured via setting
  if [ "$(basename ${SHELL})" != "zsh" ] && [ "${CODESPACES}" != "true" ]; then
    chsh -s $(which zsh)
  fi

  # install oh-my-zsh
  if [[ ! -d $HOME/.oh-my-zsh ]]; then
    echo "installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  fi

  # init zshrc
  if [[ -e $HOME/.zshrc || -L $HOME/.zshrc ]]; then
    echo "backup $HOME/.zshrc to $HOME/.zshrc.bak"
    mv $HOME/.zshrc $HOME/.zshrc.bak
  fi
  create_symlink ${src_dir}/.zshrc $HOME/.zshrc

  # install plugins
  if [[ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
    echo "installing zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  fi

  if [[ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
    echo "installing zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  fi
}

configure_git() {
  src_dir=$1

  if [[ ! -f $HOME/.gitconfig ]]; then
    echo "creating .gitconfig"
    cp ${src_dir}/git/.gitconfig $HOME/.gitconfig
  fi

  if [[ ! -f $HOME/.gitignore_global ]]; then
    echo "creating .gitignore_global"
    cp ${src_dir}/git/.gitignore_global $HOME/.gitignore_global
  fi
}

install_tools:node() {
  if [[ ! -d "$HOME/.asdf" ]]; then
    echo "installing asdf"
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.0
  fi

  # echo "installing node"
  # nvm_latest=$(curl -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
  # nvm_latest=${nvm_latest##*/}
  # curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_latest}/install.sh" | bash
  # # shellcheck disable=SC1091
  # [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
  # nvm install --lts
  # nvm use --lts
}
