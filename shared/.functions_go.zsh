# .functions_go.zsh
# Functions related to Go

install_go() {
  version=$1
  if [ -z "$version" ]; then
    echo "Usage: install_go <version>"
    return 1
  fi

  if sudo -n true 2>/dev/null; then
    # sudo is available
  else
    # request sudo password
    sudo -v
  fi

  echo "Updating go to version $version"

  osstr=$(uname -s)
  if [[ "$osstr" == "Darwin" ]]; then
    os="darwin"
  elif [[ "$osstr" == "Linux" ]]; then
    os="linux"
  else
    echo "Unsupported OS: $osstr"
    return 1
  fi

  archstr=$(uname -m)
  if [[ "$archstr" == "x86_64" ]]; then
    arch="amd64"
  elif [[ "$archstr" == "arm64" || "$archstr" == "arm" || "$archstr" == "aarch64" ]]; then
    arch="arm64"
  else
    echo "Unsupported architecture: $archstr"
    return 1
  fi

  url="https://go.dev/dl/go${version}.${os}-${arch}.tar.gz"
  echo "Downloading $url"

  if [ -z "${DOWNLOAD_DIR}" ]; then
    local DOWNLOAD_DIR="$HOME"
  fi

  file="${DOWNLOAD_DIR}/go${version}.${os}-${arch}.tar.gz"
  curl -L "$url" -o "$file"

  echo "Extracting $file"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$file"
  rm "$file"

  echo "Done"
}
