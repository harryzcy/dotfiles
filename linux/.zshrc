# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	dotenv
	golang
	python
	pip
)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="$PATH:/usr/sbin:$HOME/.local/bin"

platform_dir=$(dirname "$(realpath "$HOME/.zshrc")")
export DOTFILE_DIR="$(dirname "$platform_dir")"

export DOWNLOAD_DIR="$HOME"

source $DOTFILE_DIR/shared/.functions.zsh

export GPG_TTY=$(tty)

# load dot command
source "$DOTFILE_DIR/dot/dot.zsh"
source "$DOTFILE_DIR/dot/_dot.zsh"

if [ -z "$DISPLAY" ]; then
	PROMPT="%{$fg[green]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%} ${PROMPT}"
fi

if [[ -f "$HOME/.zshrc.local" ]]; then
	source $HOME/.zshrc.local
fi
