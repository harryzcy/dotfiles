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
  golang
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

# gh cli uses EDITOR env
export EDITOR="vim"

# HomeBrew
HOMEBREW_EDITOR="code"

export DOWNLOAD_DIR="$HOME/Downloads"

# ansible inventory
export ANSIBLE_INVENTORY=${PROJECTS_PATH}/infrastructure/inventory

# snuuze
export SNUUZE_CONFIG_FILE="$HOME/.snuuze/config.yaml"

typeset -U path
path=(
  /usr/local/go/bin # Go
  /opt/homebrew/bin # HomeBrew
  $path
  $GOPATH/bin                          # Go
  /usr/local/sbin                      # n2n
  /opt/homebrew/opt/python/libexec/bin # Python
  /opt/homebrew/opt/libpq/bin          # Postgres
  $HOME/.cargo/bin                     # Rust
  $HOME/Library/Python/3.11/bin        # Python
  /usr/local/smlnj/bin                 # SML/NJ
  $DOTFILE_DIR/dot/bin                 # dot
)
export PATH

source $platform_dir/.functions.zsh
source $platform_dir/.environments.zsh
source $platform_dir/.aliases.zsh
source $platform_dir/.completion.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
