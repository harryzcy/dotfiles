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
  elif [[ "$arch" == 'aarch64' ]]; then
    arch='arm64'
  fi
  echo $arch
}

gh_latest_version() {
  url="https://api.github.com/repos/cli/cli/releases/latest"
  if [ -z "$GITHUB_TOKEN" ]; then
    curl -s "$url" | jq -r .tag_name | cut -c 2-
  else
    # needed because GitHub rate limits in GitHub actions
    curl -s --header "Authorization: Bearer $GITHUB_TOKEN" "$url" | jq -r .tag_name | cut -c 2-
  fi
}

install_gh() {
  version=$1
  if [ -z "$version" ]; then
    echo "Usage: install_gh <version>"
    return 1
  fi

  if [[ "$(detect_os)" != "linux" ]]; then
    echo "install_gh only supports linux, use homebrew on macOS"
    return 1
  fi
  arch=$(detect_arch | sed -e 's/x86_64/amd64/')

  tmp_dir=$(mktemp -d)
  tarball_name="gh_${version}_linux_${arch}.tar.gz"
  base_url="https://github.com/cli/cli/releases/download/v${version}"

  echo "Downloading ${base_url}/${tarball_name}"
  if ! (cd "${tmp_dir}" &&
    curl -sfL -O "${base_url}/${tarball_name}" -O "${base_url}/gh_${version}_checksums.txt" &&
    grep " ${tarball_name}\$" "gh_${version}_checksums.txt" | sha256sum -c - >/dev/null &&
    tar -xzf "${tarball_name}" --strip-components=1); then
    echo "Failed to fetch and verify ${tarball_name}"
    rm -rf "${tmp_dir}"
    return 1
  fi

  mkdir -p "$DOTFILE_DIR/dot/bin"
  install -m 755 "${tmp_dir}/bin/gh" "$DOTFILE_DIR/dot/bin/gh"
  rm -rf "${tmp_dir}"
  echo "gh ${version} installed to $DOTFILE_DIR/dot/bin/gh"
}

install_zig() {
  version=$1
  if [ -z "$version" ]; then
    echo "Usage: install_zig <version>"
    return 1
  fi

  if sudo -n true 2>/dev/null; then
    # sudo is available
    echo "Sudo access is available, proceeding with installation..."
  else
    # request sudo password
    sudo -v
  fi

  os=$(detect_os)
  arch=$(detect_arch)
  if [[ "$arch" == "x86_64" ]]; then
    arch="x86_64"
  elif [[ "$arch" == "arm64" ]]; then
    arch="aarch64"
  else
    echo "Unsupported architecture: $arch"
    return 1
  fi

  if [ -z "${DOWNLOAD_DIR}" ]; then
    local DOWNLOAD_DIR="$HOME"
  fi

  pubkey="RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U"
  tarball_name="zig-${arch}-${os}-${version}.tar.xz"
  mirror="$(curl -s https://ziglang.org/download/community-mirrors.txt | head -n 1)"
  tarball_url="${mirror}/${tarball_name}"
  filepath="${DOWNLOAD_DIR}/${tarball_name}"
  echo "Downloading $tarball_url to ${filepath}"
  curl -L "$tarball_url" -o "${filepath}"
  success=$?
  if [ $success -ne 0 ]; then
    echo "Failed to download $tarball_url"
    return 1
  fi

  curl -sL "${tarball_url}.minisig" -o "${filepath}.minisig"
  minisign -Vm "${filepath}" -P "$pubkey" -x "${filepath}.minisig"
  success=$?
  if [ $success -ne 0 ]; then
    echo "Signature verification failed for $tarball_name"
    rm "$DOWNLOAD_DIR/${tarball_name}"
    return 1
  fi
  rm "${filepath}.minisig"
  echo "Successfully fetched and verified $tarball_name"

  echo "Extracting $tarball_name"
  sudo mkdir -p "/usr/local/zig"
  sudo chmod 777 "/usr/local/zig"
  tar -C "/usr/local/zig" -xf "${filepath}" --strip-components=1
  rm "${filepath}"
  echo "Zig ${version} installed to /usr/local/zig"
}
