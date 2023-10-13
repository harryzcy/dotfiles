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

# User configuration

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Go
export GOROOT=/usr/local/go
export GOPATH=$HOME/go

export PATH=/usr/local/go/bin:/opt/homebrew/bin:$PATH:${GOPATH}/bin:/opt/homebrew/opt/python/libexec/bin:/usr/local/sbin/
export PATH="$PATH:/opt/homebrew/opt/libpq/bin"

# Rust
export PATH="$PATH:$HOME/.cargo/bin"

# Python
export PATH=${PATH}:/Users/harry/Library/Python/3.11/bin

# SML/NJ
export PATH=${PATH}:/usr/local/smlnj/bin

export GPG_TTY=$(tty)

# gh cli uses EDITOR env
export EDITOR="vim"

# HomeBrew
HOMEBREW_EDITOR="code"

# follow symlink, to go to the directory with the platform specific script
platform_dir=$(dirname "$(realpath "$HOME/.zshrc")")
export DOTFILE_DIR="$(dirname "$platform_dir")"

export DOWNLOAD_DIR="$HOME/Downloads"

source $platform_dir/.functions.zsh
source $platform_dir/.environments.zsh
source $platform_dir/.aliases.zsh
source $platform_dir/.completion.zsh

source $DOTFILE_DIR/dot/dot.zsh
source "$DOTFILE_DIR/dot/_dot.zsh"
export PATH="$PATH:$DOTFILE_DIR/dot/bin"

# Projects
export PROJECTS_PATH="${HOME}/Projects"

# ansible inventory
export ANSIBLE_INVENTORY=${PROJECTS_PATH}/infrastructure/inventory

export SNUUZE_CONFIG_FILE="$HOME/.snuuze/config.yaml"

export DOT_REPO_PATH="${PROJECTS_PATH}:${HOME}/go/src/github.com/harryzcy:${HOME}/go/src/git.zcy.dev/harryzcy"
