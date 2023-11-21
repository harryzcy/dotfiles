#!/usr/bin/env zsh

set -o pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade

upgrade_awscli() {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/awscliv2.zip"
  unzip -o "$HOME/awscliv2.zip" -d "$HOME"
  sudo "$HOME/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
  rm -rf "$HOME/awscliv2.zip" "$HOME/aws"
}

upgrade_pipx() {
  echo "upgrading pipx packages"
  pipx upgrade-all
}

upgrade_golanglint() {
  echo "upgrading golangci-lint"
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
}

upgrade_rust() {
  rustup update
}

# dev machine
if [[ $(hostname -s) = gpu-* ]]; then
  upgrade_awscli
  upgrade_pipx
  upgrade_golanglint
  upgrade_krex
  upgrade_rust
  upgrade_node
fi
