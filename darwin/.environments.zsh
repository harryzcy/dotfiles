# development environment switching

init_conda() {
# >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$("${HOME}/anaconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "${HOME}/anaconda3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/anaconda3/bin:$PATH"
    fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<
}

start_esp8266 () {
  export ESP_PATH=~/esp
  export IDF_PATH=~/esp/ESP8266_RTOS_SDK
}

start_esp32 () {
  export ESP_PATH=~/esp
  export IDF_PATH=$HOME/esp/esp-idf
  # export ESPPORT=/dev/cu.SLAB_USBtoUART
  source $HOME/esp/esp-idf/export.sh
  # source ~/.espressif/python_env/idf5.0_py3.10_env/bin/activate
}

# esp related utils
function esp32_realpath_int() {
  wdir="$PWD"; [ "$PWD" = "/" ] && wdir=""
  arg=$1
  case "$arg" in
    /*) scriptdir="${arg}";;
    *) scriptdir="$wdir/${arg#./}";;
  esac
  scriptdir="${scriptdir%/*}"
  echo "$scriptdir"
}

# HyperLedger Fabric commands
init_fabric() {
  export PATH=$(go env GOPATH)/src/github.com/hyperledger/fabric-samples/bin:$PATH
}
