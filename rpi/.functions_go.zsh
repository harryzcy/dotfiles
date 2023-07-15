# .functions_go.zsh
# Functions related to Go

install_go() {
  version=$1
  if [ -z "$version" ]; then
    echo "Usage: install_go <version>"
    return 1
  fi

  sudo -v

  echo "Updating go to version $version"

  archstr=$(uname -m)
  if [[ "$archstr" == "x86_64" ]]; then
    arch="amd64"
  elif [[ "$archstr" == "arm64" || "$archstr" == "arm" ]]; then
    arch="arm64"
  else
    echo "Unsupported architecture: $archstr"
    return 1
  fi

  url="https://go.dev/dl/go${version}.linux-${arch}.tar.gz"
  echo "Downloading $url"

  file="$HOME/Downloads/go${version}.linux-${arch}.tar.gz"
  curl -L "$url" -o "$file"

  echo "Extracting $file"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$file"
  rm "$file"

  echo "Done"
}
