# Go
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"

source $DOTFILE_DIR/dev/.aliases.zsh
source $DOTFILE_DIR/dev/.variables.zsh
source $DOTFILE_DIR/dev/.environments.zsh

path=(
	/usr/local/go/bin # Go
	$path
	$HOME/.cargo/bin                         # Rust
	$GOPATH/bin                              # Go
	$HOME/.local/bin                         # uv
	$HOME/.krew/bin                          # kubectl krew
	/home/linuxbrew/.linuxbrew/bin           # HomeBrew
	$ASDF_DATA_DIR/shims                     # asdf
	/usr/local/texlive/2023/bin/x86_64-linux # TeXLive
	$DOTFILE_DIR/dot/bin                     # dot
)
export PATH

eval "$($HOME/miniconda3/bin/conda shell.zsh hook)"
eval "$(bazelisk completion)
PROMPT=$(echo "$PROMPT" | perl -pe 's/^\(base\)\s*//')

export DOT_REPO_PATH="${HOME}/Projects:${HOME}/Projects/telepresence"
