# .functions.zsh
# shared functions for all platforms

detect_os() {
  unamestr=$(uname)
  if [[ "$unamestr" == 'Linux' ]]; then
    echo "linux"
  elif [[ "$unamestr" == 'Darwin' ]]; then
    echo "macos"
  else
    echo "unsupported platform: $platform"
    exit 1
  fi
}

detect_arch() {
  arch=$(uname -m)
  if [[ "$arch" == 'aar64' ]]; then
    arch='arm64'
  fi
  echo $arch
}

source $DOTFILE_DIR/shared/.functions_go.zsh

docker_prune() {
  docker system prune -a
}
