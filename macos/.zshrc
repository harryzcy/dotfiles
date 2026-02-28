# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
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

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# follow symlink, to go to the directory with the platform specific script
platform_dir=$(dirname "$(realpath "$HOME/.zshrc")")
export DOTFILE_DIR="$(dirname "$platform_dir")"

# Projects
export PROJECTS_PATH="${HOME}/Projects"

# dot command
source $DOTFILE_DIR/dot/dot.zsh
source $DOTFILE_DIR/dot/_dot.zsh
export DOT_REPO_PATH="${PROJECTS_PATH}:${HOME}/go/src/github.com/harryzcy:${HOME}/go/src/git.zcy.dev/harryzcy"

# Go
export GOROOT=/usr/local/go
export GOPATH=$HOME/go

export GPG_TTY=$(tty)

typeset -U path
path=(
  /usr/local/go/bin # Go
  /opt/homebrew/bin # HomeBrew
  $path
  $HOME/.bun/bin                     # Bun
  $GOPATH/bin                          # Go
  $HOME/.local/bin                     # uv
  /usr/local/sbin                      # n2n
  /opt/homebrew/opt/python/libexec/bin # Python
  /opt/homebrew/opt/libpq/bin          # Postgres
  $HOME/.cargo/bin                     # Rust
  $DOTFILE_DIR/dot/bin                 # dot
)
export PATH

# Ruby
eval "$(rbenv init - zsh)"

source "$platform_dir/.functions.zsh"
source "$platform_dir/.completion.zsh"
source "$DOTFILE_DIR/dev/.aliases.zsh"
source "$DOTFILE_DIR/dev/.variables.zsh"
source "$DOTFILE_DIR/dev/.environments.zsh"

if [[ -f "$HOME/.zshrc.local" ]]; then
  source $HOME/.zshrc.local
fi
