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

export PATH=/opt/homebrew/bin:/opt/homebrew/opt/python/libexec/bin:$PATH:/usr/local/sbin/:/usr/local/go/bin:${GOPATH}/bin

# Rust
export PATH="$PATH:$HOME/.cargo/bin"

# Python
export PATH=${PATH}:/Users/harry/Library/Python/3.11/bin

# nvm
lazy_load_nvm() {
  unset -f npm node nvm
  export NVM_DIR=~/.nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  # add nvm to the end instead of the beginning
  export PATH="$(nvm_strip_path "${PATH}" "/bin"):$(dirname "$(which node)")"
}

npm() {
 lazy_load_nvm
 npm $@
}

node() {
  lazy_load_nvm
  node $@
}

nvm() {
  lazy_load_nvm
  nvm $@
}

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

source $DOTFILE_DIR/dot/dot.zsh
export PATH="$PATH:$DOTFILE_DIR/dot/bin"

source <(kubectl completion zsh)
source <(helm completion zsh)
# ansible completion
eval $(register-python-argcomplete ansible)
eval $(register-python-argcomplete ansible-config)
eval $(register-python-argcomplete ansible-console)
eval $(register-python-argcomplete ansible-doc)
eval $(register-python-argcomplete ansible-galaxy)
eval $(register-python-argcomplete ansible-inventory)
eval $(register-python-argcomplete ansible-playbook)
eval $(register-python-argcomplete ansible-pull)
eval $(register-python-argcomplete ansible-vault)

export SNUUZE_CONFIG_FILE="$HOME/.snuuze/config.yaml"

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export DOT_REPO_PATH="$HOME/Projects:$HOME/go/src/github.com/harryzcy:$HOME/go/src/git.harryzheng.com/harryzcy"

# Aliases
alias kak="kubectl apply -k"
