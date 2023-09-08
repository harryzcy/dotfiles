export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

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

export PATH="$PATH:/usr/sbin:$HOME/.local/bin"

platform_dir=$(dirname "$(realpath "$HOME/.zshrc")")
export DOTFILE_DIR="$(dirname "$platform_dir")"

# load dot command
source "$DOTFILE_DIR/dot/dot.zsh"
source "$DOTFILE_DIR/dot/_dot.zsh"
