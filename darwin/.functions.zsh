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
