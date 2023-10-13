# Environment variables
if [ -f $HOME/.env ]; then
  export $(cat $HOME/.env | xargs)
fi

# Python
lazy_load_conda() {
  unset -f conda

  conda_dir="$HOME/miniconda3"
  if [ ! -d "$conda_dir" ]; then
    conda_dir="$HOME/anaconda3"
  fi

  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$("${conda_dir}/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "${conda_dir}/etc/profile.d/conda.sh" ]; then
      . "${conda_dir}/etc/profile.d/conda.sh"
    else
      export PATH="${conda_dir}/bin:$PATH"
    fi
  fi
  unset __conda_setup
}

conda() {
  lazy_load_conda
  conda $@
}

# Node & nvm
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

# Kubectl
chk3s() {
  if [ -n "$1" ] && [ $1 = "-h" ]; then
    echo "Usage: chk3s <cluster>"
    return
  fi

  cluster=${1:-default}

  kubectl config use-context $cluster
}

start_esp8266() {
  export ESP_PATH=~/esp
  export IDF_PATH=~/esp/ESP8266_RTOS_SDK
}

start_esp32() {
  export ESP_PATH=~/esp
  export IDF_PATH=$HOME/esp/esp-idf
  # export ESPPORT=/dev/cu.SLAB_USBtoUART
  source $HOME/esp/esp-idf/export.sh
  # source ~/.espressif/python_env/idf5.0_py3.10_env/bin/activate
}

# esp related utils
esp32_realpath_int() {
  wdir="$PWD"
  [ "$PWD" = "/" ] && wdir=""
  arg=$1
  case "$arg" in
  /*) scriptdir="${arg}" ;;
  *) scriptdir="$wdir/${arg#./}" ;;
  esac
  scriptdir="${scriptdir%/*}"
  echo "$scriptdir"
}

# HyperLedger Fabric commands
init_fabric() {
  export PATH=$(go env GOPATH)/src/github.com/hyperledger/fabric-samples/bin:$PATH
}
