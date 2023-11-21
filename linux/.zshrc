# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  git
  web-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  golang
  python
  pip
  dotenv
  kubectl
)

source $ZSH/oh-my-zsh.sh

# User configuration

platform_dir=$(dirname "$(realpath "$HOME/.zshrc")")
export DOTFILE_DIR="$(dirname "$platform_dir")"

export GPG_TTY=$(tty)

# load dot command
source "$DOTFILE_DIR/dot/dot.zsh"
source "$DOTFILE_DIR/dot/_dot.zsh"

source $DOTFILE_DIR/shared/.functions.zsh

if [ -z "$DISPLAY" ]; then
  PROMPT="%{$fg[green]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%} ${PROMPT}"
fi

if [[ $(hostname -s) = gpu-* ]]; then
  source $DOTFILE_DIR/linux/dev.environments.zsh
fi

if [[ -f "$HOME/.zshrc.local" ]]; then
  source $HOME/.zshrc.local
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
