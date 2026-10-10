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

upgrade_asdf() {
  # check the managed binary directly, a Homebrew-installed asdf may shadow it on PATH
  current_version=$("$DOTFILE_DIR/dot/bin/asdf" version 2>/dev/null | awk '{print $1}' | sed 's/^v//')
  latest_version=$(asdf_latest_version)
  if version_gt "$latest_version" "$current_version"; then
    echo "upgrading asdf"
    install_asdf "$latest_version"
  fi
}

upgrade_node() {
  source $DOTFILE_DIR/dev/.environments.zsh

  asdf plugin update --all
  # update node-build
  asdf cmd nodejs update-nodebuild

  # upgrade node
  node_latest=$(asdf latest nodejs)
  node_current=$(asdf current nodejs --no-header | awk '{print $2}')
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
  uv_current=$(uv --version 2>/dev/null | awk '{print $2}')
  uv_latest=$(uv_latest_version)
  if version_gt "$uv_latest" "$uv_current"; then
    echo "upgrading uv"
    install_uv "$uv_latest"
  fi
  python_path=$(uv python list --only-installed --managed-python | head -n 1 | awk '{print $2}')
  latest_version=$(curl -s https://endoflife.date/api/python.json | jq -r '.[0].latest')
  if [ -z "$python_path" ]; then
    echo "installing python"
    uv python install "$latest_version"
  else
    current_version=$("$python_path" --version | awk '{print $2}')
    if [ "$current_version" != "$latest_version" ]; then
      echo "upgrading python"
      uv python install "$latest_version" && uv python uninstall "$current_version"
    fi
  fi
  uv tool upgrade --all
}

upgrade_terraform() {
  source $DOTFILE_DIR/dev/.environments.zsh

  asdf plugin update --all

  # upgrade terraform
  tf_latest=$(asdf latest terraform)
  tf_current=$(asdf current terraform --no-header | awk '{print $2}')
  if [ "$tf_latest" != "$tf_current" ]; then
    echo "upgrading terraform"
    asdf install terraform latest
    asdf set --home terraform latest
    asdf uninstall terraform "$tf_current"
  fi
}

upgrade_cosign() {
  current_version=$(cosign version 2>&1 | awk '$1 == "GitVersion:" { print $2 }' | sed 's/^v//')
  latest_version=$(cosign_latest_version)
  if version_gt "$latest_version" "$current_version"; then
    echo "upgrading cosign"
    install_cosign "$latest_version"
  fi
}

upgrade_opentofu() {
  source $DOTFILE_DIR/dev/.environments.zsh

  asdf plugin update --all

  # upgrade opentofu
  tofu_latest=$(asdf latest opentofu)
  tofu_current=$(asdf current opentofu --no-header | awk '{print $2}')
  if [ "$tofu_latest" != "$tofu_current" ]; then
    echo "upgrading opentofu"
    asdf install opentofu latest
    asdf set --home opentofu latest
    asdf uninstall opentofu "$tofu_current"
  fi
}

upgrade_awscli() {
  current_version=$(aws --version 2>/dev/null | awk '{print $1}' | cut -d/ -f2)
  latest_version=$(curl -s https://api.github.com/repos/aws/aws-cli/tags | jq -r '.[0].name')

  if version_gt "$latest_version" "$current_version"; then
    echo "upgrading awscli"
    tmp_dir=$(mktemp -d)
    zip_url="https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${latest_version}.zip"
    if ! curl -fsSL "$zip_url" -o "$tmp_dir/awscliv2.zip" ||
      ! curl -fsSL "${zip_url}.sig" -o "$tmp_dir/awscliv2.zip.sig"; then
      echo "Failed to download $zip_url"
      rm -rf "$tmp_dir"
      return 1
    fi
    if ! verify_gpg_signature "$tmp_dir/awscliv2.zip" "$tmp_dir/awscliv2.zip.sig" "$AWS_CLI_PUBLIC_KEY" "$AWS_CLI_KEY_FINGERPRINT"; then
      echo "Signature verification failed for $zip_url"
      rm -rf "$tmp_dir"
      return 1
    fi

    unzip -q "$tmp_dir/awscliv2.zip" -d "$tmp_dir"
    archive_version=$("$tmp_dir/aws/dist/aws" --version 2>&1 | awk '{print $1}' | cut -d/ -f2)
    if [ "$archive_version" != "$latest_version" ]; then
      echo "Archive contains awscli ${archive_version:-unknown}, expected $latest_version"
      rm -rf "$tmp_dir"
      return 1
    fi
    sudo "$tmp_dir/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
    rm -rf "$tmp_dir"
  fi
}

upgrade_bazelisk() {
  echo "upgrading bazelisk"
  install_bazelisk
}

upgrade_gh() {
  # check the managed binary directly, an apt-installed gh may shadow it on PATH
  current_version=$("$DOTFILE_DIR/dot/bin/gh" --version 2>/dev/null | head -n 1 | awk '{print $3}')
  latest_version=$(gh_latest_version)

  if [ "$current_version" != "$latest_version" ]; then
    echo "upgrading gh"
    install_gh "$latest_version"
  fi
}

upgrade_go() {
  echo "upgrading go"
  current_version=$(go version | awk '{print $3}' | cut -c 3-)
  latest_version=$(curl -s 'https://go.dev/VERSION?m=text' | head -n 1 | cut -c 3-)
  echo "current version: $current_version"
  echo "latest version: $latest_version"
  if version_gt "$latest_version" "$current_version"; then
    source "$DOTFILE_DIR/shared/.functions_go.zsh"
    install_go "$latest_version"
  fi

  lint_current=$(golangci-lint version --short 2>/dev/null)
  lint_latest=$(golangci_lint_latest_version)
  if version_gt "$lint_latest" "$lint_current"; then
    echo "upgrading golangci-lint"
    install_golangci_lint "$lint_latest" "$(go env GOPATH)/bin"
  fi
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
  upgrade_gh
  upgrade_go
  upgrade_krex
  upgrade_bazelisk
  upgrade_rust
  upgrade_asdf
  upgrade_node
  upgrade_python
  upgrade_terraform
  upgrade_cosign
  upgrade_opentofu
fi
