# setup functions common to all platforms

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
  if [[ -f $HOME/.zshrc ]]; then
    if [[ ! -L $HOME/.zshrc ]]; then
      echo "backup $HOME/.zshrc to $HOME/.zshrc.bak"
      mv $HOME/.zshrc $HOME/.zshrc.bak

      echo "creating symlink for .zshrc"
      ln -s ${src_dir}/.zshrc $HOME/.zshrc
    fi
  else
    echo "creating symlink for .zshrc"
    ln -s ${src_dir}/.zshrc $HOME/.zshrc
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

configure_git() {
  src_dir=$1

  if [[ ! -f $HOME/.gitconfig ]]; then
    echo "creating symlink for .gitconfig"
    ln -s ${src_dir}/git/.gitconfig $HOME/.gitconfig
  fi

  if [[ ! -f $HOME/.gitignore_global ]]; then
    echo "creating symlink for .gitignore_global"
    ln -s ${src_dir}/git/.gitignore_global $HOME/.gitignore_global
  fi
}
