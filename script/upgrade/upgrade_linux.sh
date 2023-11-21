#!/usr/bin/env zsh

set -o pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update
sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade

# dev machine
if [[ $(hostname -s) = gpu-* ]]; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/awscliv2.zip"
  unzip -o "$HOME/awscliv2.zip" -d "$HOME"
  sudo "$HOME/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
  rm -rf "$HOME/awscliv2.zip" "$HOME/aws"

  echo "upgrading pipx packages"
  pipx upgrade-all

  echo "upgrading golangci-lint"
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin

  kubectl krew update
  kubectl krew upgrade

  rustup update

  # upgrade nvm
  nvm_latest=$(curl -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
  nvm_latest=${nvm_latest##*/}
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_latest}/install.sh" | bash

  # upgrade npm and node
  nvm install --lts --latest-npm --reinstall-packages-from='lts/*'
fi
