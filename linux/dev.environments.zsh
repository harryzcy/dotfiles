# Go
export GOROOT=/usr/local/go
export GOPATH=$HOME/go

path=(
	/usr/local/go/bin # Go
	$path
	$HOME/.cargo/bin # Rust
	$GOPATH/bin      # Go
	$HOME/.local/bin # pipx
)
export PATH

eval "$($HOME/miniconda3/bin/conda shell.zsh hook)"
PROMPT=$(echo "$PROMPT" | perl -pe 's/^\(base\)\s*//')

source $DOTFILE_DIR/dev/.aliases.zsh
source $DOTFILE_DIR/dev/.variables.zsh
source $DOTFILE_DIR/dev/.environments.zsh

export DOT_REPO_PATH="${HOME}/Projects:${HOME}/Projects/telepresence"
