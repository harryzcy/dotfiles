#!/usr/bin/env bash

set -o pipefail

install_xcode_select() {
  if ! xcode-select -p &>/dev/null; then
    sudo xcode-select --install
  fi
}

install_tools() {
  echo "installing tools for macOS"
  run_brew_install git
  run_brew_install zsh
  run_brew_install coreutils
  run_brew_install cloc
  run_brew_install curl
  run_brew_install gh
  run_brew_install httpie
  run_brew_install jq
  run_brew_install python3
  run_brew_install tree
  run_brew_install wget
  run_brew_install gnupg
  run_brew_install ansible
  install_tools:argcomplete # needed for autocompletion for ansible
  run_brew_install helm
  run_brew_install kubectl
  run_brew_install gawk # required by asdf
  run_brew_install minisign
  install_tools:bun

  brew tap mac-cleanup/mac-cleanup-py
  run_brew_install mac-cleanup-py

  # krew
  (
    set -x
    cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
  )
}

install_tools:argcomplete() {
  if ! command -v register-python-argcomplete &>/dev/null; then
    echo "installing argcomplete"
    pip3 install argcomplete
  fi
}

install_software() {
  echo "installing software for macOS"

  arch=$(uname -m)

  notion_url="https://www.notion.so/desktop/mac-universal/download"
  if [ "$arch" = "arm64" ]; then
    vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=darwin-arm64-dmg"
    docker_url="https://desktop.docker.com/mac/stable/arm64/Docker.dmg"
  else
    vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=darwin-x64-dmg"
    docker_url="https://desktop.docker.com/mac/stable/amd64/Docker.dmg"
  fi

  install_dmg "Google Chrome" "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  install_dmg "Visual Studio Code" "$vscode_url" "/Applications/Visual Studio Code.app/Contents/MacOS/Electron"
  install_dmg "Notion" "$notion_url" "/Applications/Notion.app/Contents/MacOS/Notion"
  install_dmg "Keka" "https://d.keka.io/" "/Applications/Keka.app/Contents/MacOS/Keka"
  install_zip "iTerm2" "https://iterm2.com/downloads/stable/latest" "/Applications/iTerm.app/Contents/MacOS/iTerm2"

  if [ -z "$GITHUB_TOKEN" ]; then
    iina_version=$(curl -s https://api.github.com/repos/iina/iina/releases/latest | grep tag_name | cut -d : -f 2,3 | tr -d \"\ \,)
  else
    # needed because if GitHub rate limits in GitHub actions
    echo "using GitHub token to get latest IINA version"
    iina_version=$(curl -s --header "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/repos/iina/iina/releases/latest | grep tag_name | cut -d : -f 2,3 | tr -d \"\ \,)
  fi
  install_dmg "IINA" "https://dl-portal.iina.io/IINA.${iina_version}.dmg" "/Applications/IINA.app/Contents/MacOS/IINA"

  install_dmg "Docker" "$docker_url" "/Applications/Docker.app/Contents/MacOS/Docker"
}

configure_dot_bin() {
  if [ ! -d "$DOTFILE_DIR/dot/bin" ]; then
    echo "creating $DOTFILE_DIR/dot/bin"
    mkdir "$DOTFILE_DIR/dot/bin"
  fi

  if [ ! -f "$DOTFILE_DIR/dot/bin/chrome" ]; then
    cat >"$DOTFILE_DIR/dot/bin/chrome" <<EOT
#!/usr/bin/env zsh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "\$@"
EOT
  fi
  chmod +x "$DOTFILE_DIR/dot/bin/chrome"

  create_symlink "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "$DOTFILE_DIR/dot/bin/code"

  create_symlink \
    "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/msupdate" \
    "$DOTFILE_DIR/dot/bin/msupdate"
}

configure_hammerspoon() {
  echo "initializing hammerspoon"
  create_symlink "$DOTFILE_DIR/macos/hammerspoon" "$HOME/.hammerspoon"
}

install_xcode_select
if [[ "${NO_INSTALL}" != "true" ]]; then
  install_homebrew
  install_tools
  install_software
fi

configure_git "${DOTFILE_DIR}/macos"
configure_zsh "${DOTFILE_DIR}/macos"
configure_hammerspoon
configure_dot_bin
