#!/usr/bin/env zsh

set -o pipefail

upgrade_apt() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade
}

upgrade_node() {
  source $DOTFILE_DIR/dev/.environments.zsh

  asdf update
  asdf plugin update --all

  # upgrade node
  node_latest=$(asdf latest nodejs)
  node_current=$(asdf current nodejs | awk '{print $2}')
  if [ "$node_latest" != "$node_current" ]; then
    echo "upgrading node"
    asdf install nodejs latest
    asdf global nodejs latest
    asdf uninstall nodejs "$node_current"

    # reinstall global packages
    npm install -g "${node_packaegs[@]}"
  fi
}

upgrade_awscli() {
  current_version=$(aws --version 2>&1 | awk '{print $1}' | cut -d/ -f2)
  latest_version=$(curl -s https://api.github.com/repos/aws/aws-cli/tags | jq -r '.[0].name')

  if [ "$current_version" != "$latest_version" ]; then
    echo "upgrading awscli"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/awscliv2.zip"
    unzip -o "$HOME/awscliv2.zip" -d "$HOME"
    sudo "$HOME/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
    rm -rf "$HOME/awscliv2.zip" "$HOME/aws"
  fi
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

### Main Script ###
upgrade_apt
upgrade_zsh

# dev machine
if [[ "$IS_DEV_MACHINE" = true ]]; then
  upgrade_awscli
  upgrade_pipx
  upgrade_golanglint
  upgrade_krex
  upgrade_rust
  upgrade_node
fi
