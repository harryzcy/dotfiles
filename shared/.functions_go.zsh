# .functions_go.zsh
# Functions related to Go

source "$DOTFILE_DIR/shared/.keys.sh"

verify_go_signature() {
  local file=$1
  local signature_url=$2

  local public_key signature
  signature=$(mktemp)
  public_key=$(curl -fsSL "https://dl.google.com/linux/linux_signing_key.pub") &&
    curl -fsSL "$signature_url" -o "$signature" &&
    verify_gpg_signature "$file" "$signature" "$public_key" "$GOOGLE_LINUX_SIGNING_KEY_FINGERPRINT"
  local result=$?
  rm -f "$signature"
  return $result
}

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

  if command -v sha256sum &>/dev/null; then
    sha256_cmd=(sha256sum)
  elif command -v shasum &>/dev/null; then
    sha256_cmd=(shasum -a 256)
  else
    echo "sha256sum or shasum is required to verify the download"
    return 1
  fi

  if ! command -v gpg &>/dev/null || ! command -v gpgv &>/dev/null; then
    echo "gpg and gpgv are required to verify the download"
    return 1
  fi

  tarball_name="go${version}.${os}-${arch}.tar.gz"
  url="https://dl.google.com/go/${tarball_name}"

  expected_sha256=$(curl -fsSL "${url}.sha256")
  if [[ ! "$expected_sha256" =~ ^[0-9a-f]{64}$ ]]; then
    echo "Failed to fetch checksum for $tarball_name"
    return 1
  fi

  if [ -z "${DOWNLOAD_DIR}" ]; then
    local DOWNLOAD_DIR="$HOME"
  fi

  file="${DOWNLOAD_DIR}/${tarball_name}"
  echo "Downloading $url"
  if ! curl -fL "$url" -o "$file"; then
    echo "Failed to download $url"
    rm -f "$file"
    return 1
  fi

  actual_sha256=$("${sha256_cmd[@]}" "$file" | awk '{print $1}')
  if [[ "$actual_sha256" != "$expected_sha256" ]]; then
    echo "Checksum verification failed for $tarball_name"
    rm "$file"
    return 1
  fi

  if ! verify_go_signature "$file" "${url}.asc"; then
    echo "Signature verification failed for $tarball_name"
    rm "$file"
    return 1
  fi

  archive_version=$(tar -xzOf "$file" go/VERSION 2>/dev/null | head -n 1)
  if [[ "$archive_version" != "go${version}" ]]; then
    echo "Archive contains ${archive_version:-no version}, expected go${version}"
    rm "$file"
    return 1
  fi
  echo "Successfully fetched and verified $tarball_name"

  echo "Extracting $file"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$file"
  rm "$file"

  echo "Done"
}
