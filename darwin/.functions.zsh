# .functions.zsh
# A list of helper functions

update_time() {
  sudo sntp -sS time.apple.com
}

function set_proxy() {
  export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7891
}

function unset_proxy() {
  export https_proxy= http_proxy= all_proxy=
}

dir=$(dirname "$0")
source $dir/.functions_docker.zsh
source $DOTFILE_DIR/shared/.functions.zsh

if [ -f $HOME/.env ]; then
  export $(cat $HOME/.env | xargs)
fi

function chk3s() {
  if [ -n "$1" ] && [ $1 = "-h" ]; then
    echo "Usage: chk3s <cluster>"
    return
  fi

  cluster=${1:-default}

  kubectl config use-context $cluster
}

# nvm
lazy_load_nvm() {
  unset -f npm node nvm npx yarn
  export NVM_DIR=~/.nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
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

npx() {
  lazy_load_nvm
  npx $@
}

yarn() {
  lazy_load_nvm
  yarn $@
}
