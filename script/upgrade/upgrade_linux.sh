#!/usr/bin/env zsh

set -o pipefail

node_packages=(
  npm-check-updates
  serverless
  wrangler
  yarn
)

upgrade_apt() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update
  sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade
}

upgrade_node() {
  source $DOTFILE_DIR/dev/.environments.zsh

  asdf plugin update --all
  # update node-build
  asdf cmd nodejs update-nodebuild

  # upgrade node
  node_latest=$(asdf latest nodejs)
  node_current=$(asdf current nodejs | awk '{print $2}')
  if [ "$node_latest" != "$node_current" ]; then
    echo "upgrading node"
    asdf install nodejs latest
    asdf set --home nodejs latest
    asdf uninstall nodejs "$node_current"

    # reinstall global packages
    npm install -g "${node_packages[@]}"
    asdf reshim # https://github.com/asdf-vm/asdf-nodejs/issues/421
  fi
}

upgrade_python() {
  uv self update
  python_path=$(uv python list --only-installed --managed-python | head -n 1 | awk '{print $2}')
  current_version=$("$python_path" --version | awk '{print $2}')
  latest_version=$(curl -s https://endoflife.date/api/python.json | jq -r '.[0].latest')
  if [ "$current_version" != "$latest_version" ]; then
    echo "upgrading python"
    uv python install "$latest_version"
    uv python uninstall "$current_version"
  fi
  uv tool upgrade --all
}

upgrade_awscli() {
  current_version=$(aws --version 2>&1 | awk '{print $1}' | cut -d/ -f2)
  latest_version=$(curl -s https://api.github.com/repos/aws/aws-cli/tags | jq -r '.[0].name')

  if [ "$current_version" != "$latest_version" ]; then
    echo "upgrading awscli"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/awscliv2.zip"
    unzip -o "$HOME/awscliv2.zip" -d "$HOME" >/dev/null
    sudo "$HOME/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
    rm -rf "$HOME/awscliv2.zip" "$HOME/aws"
  fi
}

upgrade_bazelisk() {
  echo "upgrading bazelisk"
  latest_version=$(curl -s https://api.github.com/repos/bazelbuild/bazelisk/releases/latest | jq -r .tag_name)
  curl -L "https://github.com/bazelbuild/bazelisk/releases/download/$latest_version/bazelisk-linux-amd64" -o "$DOTFILE_DIR/dot/bin/bazelisk"
  chmod +x "$DOTFILE_DIR/dot/bin/bazelisk"
}

upgrade_go() {
  echo "upgrading go"
  current_version=$(go version | awk '{print $3}' | cut -c 3-)
  latest_version=$(curl -s 'https://go.dev/VERSION?m=text' | head -n 1 | cut -c 3-)
  echo "current version: $current_version"
  echo "latest version: $latest_version"
  if [ "$current_version" != "$latest_version" ]; then
    source "$DOTFILE_DIR/shared/.functions_go.zsh"
    install_go "$latest_version"
  fi

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
  upgrade_go
  upgrade_krex
  upgrade_bazelisk
  upgrade_rust
  upgrade_node
  upgrade_python
fi
