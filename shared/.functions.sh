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

install_zig() {
  version=$1
  if [ -z "$version" ]; then
    echo "Usage: install_zig <version>"
    return 1
  fi

  if sudo -n true 2>/dev/null; then
    # sudo is available
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
