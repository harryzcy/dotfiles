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
  asdf
  golang
  helm
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

source "$DOTFILE_DIR/shared/.functions.zsh"
source "$DOTFILE_DIR/shared/.environments.sh"

if [ -z "$DISPLAY" ]; then
  PROMPT="%{$fg[green]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%} ${PROMPT}"
fi

if [[ "$IS_DEV_MACHINE" = true ]]; then
  source $DOTFILE_DIR/linux/dev.environments.zsh
else
  export DOWNLOAD_DIR="$HOME"
fi

if [[ -f "$HOME/.zshrc.local" ]]; then
  source $HOME/.zshrc.local
fi
