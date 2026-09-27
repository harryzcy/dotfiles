#!/usr/bin/env bash

# shellcheck source=SCRIPTDIR/.keys.sh
source "$DOTFILE_DIR/shared/.keys.sh"

detect_os() {
  unamestr=$(uname)
  if [[ "$unamestr" == 'Linux' ]]; then
    echo "linux"
  elif [[ "$unamestr" == 'Darwin' ]]; then
    echo "macos"
  else
    echo "unsupported platform: $unamestr" >&2
    return 1
  fi
}

detect_arch() {
  arch=$(uname -m)
  if [[ "$arch" == 'aarch64' ]]; then
    arch='arm64'
  fi
  echo "$arch"
}

# version_gt <a> <b> succeeds if version a is newer than version b
version_gt() {
  [ "$1" != "$2" ] && [ "$(printf '%s\n' "$1" "$2" | sort -V | tail -n 1)" = "$1" ]
}

# file_sha256 <file> prints the sha256 of file
file_sha256() {
  if command -v sha256sum &>/dev/null; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum &>/dev/null; then
    # macOS before 15 has shasum but not sha256sum
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "sha256sum or shasum is required to verify the download" >&2
    return 1
  fi
}

# verify_gpg_signature <file> <signature file> <armored public key> <primary key fingerprint>
# succeeds only if the signature was made by the key with that primary fingerprint
verify_gpg_signature() {
  local file=$1
  local signature=$2
  local public_key=$3
  local fingerprint=$4

  if ! command -v gpg &>/dev/null || ! command -v gpgv &>/dev/null; then
    echo "gpg and gpgv are required to verify signatures"
    return 1
  fi

  local gpg_dir
  gpg_dir=$(mktemp -d)
  gpg --homedir "$gpg_dir" --dearmor --output "${gpg_dir}/key.gpg" <<<"$public_key" &&
    gpgv --homedir "$gpg_dir" --status-fd 1 --keyring "${gpg_dir}/key.gpg" "$signature" "$file" 2>/dev/null |
    awk -v fpr="$fingerprint" '$2 == "VALIDSIG" && $NF == fpr { found = 1 } END { exit !found }'
  local result=$?
  rm -rf "$gpg_dir"
  return $result
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

golangci_lint_latest_version() {
  curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/golangci/golangci-lint/releases/latest | sed 's|.*/tag/v||'
}

# install_golangci_lint <version> <bin dir>
install_golangci_lint() {
  version=$1
  bin_dir=$2
  if [ -z "$version" ] || [ -z "$bin_dir" ]; then
    echo "Usage: install_golangci_lint <version> <bin dir>"
    return 1
  fi

  os=$(uname | tr '[:upper:]' '[:lower:]')
  arch=$(detect_arch | sed -e 's/x86_64/amd64/')
  name="golangci-lint-${version}-${os}-${arch}"
  base_url="https://github.com/golangci/golangci-lint/releases/download/v${version}"

  tmp_dir=$(mktemp -d)
  echo "Downloading ${base_url}/${name}.tar.gz"
  if ! (cd "${tmp_dir}" &&
    curl -fsSL -O "${base_url}/${name}.tar.gz" -O "${base_url}/golangci-lint-${version}-checksums.txt"); then
    echo "Failed to download ${name}.tar.gz"
    rm -rf "${tmp_dir}"
    return 1
  fi
  # the checksum file names each archive with its version, so this also checks the version
  expected_sha256=$(awk -v name="${name}.tar.gz" '$2 == name { print $1 }' "${tmp_dir}/golangci-lint-${version}-checksums.txt")
  if [ -z "$expected_sha256" ] || [[ "$(file_sha256 "${tmp_dir}/${name}.tar.gz")" != "$expected_sha256" ]]; then
    echo "Checksum verification failed for ${name}.tar.gz"
    rm -rf "${tmp_dir}"
    return 1
  fi

  tar -xzf "${tmp_dir}/${name}.tar.gz" -C "${tmp_dir}"
  mkdir -p "$bin_dir"
  install -m 755 "${tmp_dir}/${name}/golangci-lint" "${bin_dir}/golangci-lint"
  rm -rf "${tmp_dir}"
  echo "golangci-lint ${version} installed to ${bin_dir}/golangci-lint"
}

install_bazelisk() {
  if [[ "$(detect_os)" != "linux" ]]; then
    echo "install_bazelisk only supports linux"
    return 1
  fi
  arch=$(detect_arch | sed -e 's/x86_64/amd64/')

  tmp_dir=$(mktemp -d)
  binary_name="bazelisk-linux-${arch}"
  url="https://github.com/bazelbuild/bazelisk/releases/latest/download/${binary_name}"

  echo "Downloading ${url}"
  if ! curl -fsSL "$url" -o "${tmp_dir}/bazelisk" ||
    ! expected_sha256=$(curl -fsSL "${url}.sha256"); then
    echo "Failed to download ${binary_name}"
    rm -rf "${tmp_dir}"
    return 1
  fi
  if [[ ! "$expected_sha256" =~ ^[0-9a-f]{64}$ ]] || [[ "$(file_sha256 "${tmp_dir}/bazelisk")" != "$expected_sha256" ]]; then
    echo "Checksum verification failed for ${binary_name}"
    rm -rf "${tmp_dir}"
    return 1
  fi

  mkdir -p "$DOTFILE_DIR/dot/bin"
  install -m 755 "${tmp_dir}/bazelisk" "$DOTFILE_DIR/dot/bin/bazelisk"
  ln -sf "$DOTFILE_DIR/dot/bin/bazelisk" "$DOTFILE_DIR/dot/bin/bazel"
  rm -rf "${tmp_dir}"
  echo "bazelisk installed to $DOTFILE_DIR/dot/bin/bazelisk"
}

install_krew() {
  os=$(uname | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')
  archive_name="krew-${os}_${arch}.tar.gz"

  # take the download URL and checksum from krew-index, which is reviewed separately from releases
  index_url="https://raw.githubusercontent.com/kubernetes-sigs/krew-index/master/plugins/krew.yaml"
  local url expected_sha256
  read -r url expected_sha256 < <(curl -fsSL "$index_url" | awk -v name="/${archive_name}" '
    $2 == "uri:" { uri = $3 }
    $1 == "sha256:" && substr(uri, length(uri) - length(name) + 1) == name { print uri, $2; exit }')
  if [ -z "$url" ] || [ -z "$expected_sha256" ]; then
    echo "Failed to find ${archive_name} in ${index_url}"
    return 1
  fi

  tmp_dir=$(mktemp -d)
  echo "Downloading ${url}"
  if ! curl -fsSL "$url" -o "${tmp_dir}/${archive_name}"; then
    echo "Failed to download ${url}"
    rm -rf "${tmp_dir}"
    return 1
  fi
  if [[ "$(file_sha256 "${tmp_dir}/${archive_name}")" != "$expected_sha256" ]]; then
    echo "Checksum verification failed for ${archive_name}"
    rm -rf "${tmp_dir}"
    return 1
  fi

  tar -xzf "${tmp_dir}/${archive_name}" -C "${tmp_dir}" &&
    "${tmp_dir}/krew-${os}_${arch}" install krew
  local result=$?
  rm -rf "${tmp_dir}"
  return $result
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
  trusted_comment=$(minisign -Vm "${filepath}" -P "$ZIG_MINISIGN_PUBLIC_KEY" -x "${filepath}.minisig" -Q)
  success=$?
  if [ $success -ne 0 ]; then
    echo "Signature verification failed for $tarball_name"
    rm "${filepath}" "${filepath}.minisig"
    return 1
  fi
  # verify the trusted comment names the requested filename
  if ! tr -s '[:space:]' '\n' <<<"$trusted_comment" | grep -qxF "file:${tarball_name}"; then
    echo "Signature is for a different file than $tarball_name: $trusted_comment"
    rm "${filepath}" "${filepath}.minisig"
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
