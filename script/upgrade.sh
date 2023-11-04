#!/usr/bin/env zsh

# update oh-my-zsh
if [ -z "$ZSH" ]; then
  ZSH="$HOME/.oh-my-zsh"
fi
ZSH="$ZSH" command zsh -f "$ZSH/tools/upgrade.sh" || return $?

echo "updating zsh-autosuggestions"
git -C $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions pull >/dev/null

echo "updating zsh-syntax-highlighting"
git -C $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting pull >/dev/null

# update common tools
source $DOTFILE_DIR/shared/.functions.sh
os=$(detect_os)
if [[ "$os" == 'linux' ]]; then
  # linux
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade

  # if awscli is installed, upgrade it
  if command -v aws &>/dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/awscliv2.zip"
    unzip -o "$HOME/awscliv2.zip" -d "$HOME"
    sudo "$HOME/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
    rm -rf "$HOME/awscliv2.zip" "$HOME/aws"
  fi

elif [[ "$os" == 'macos' ]]; then
  # macos
  brew update && brew upgrade
  brew upgrade --cask

  # upgrade nvm
  nvm_latest=$(curl -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
  nvm_latest=${nvm_latest##*/}
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_latest}/install.sh" | bash
fi
