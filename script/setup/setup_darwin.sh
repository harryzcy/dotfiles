#!/usr/bin/env bash

install_xcode_select() {
  if ! xcode-select -p &> /dev/null
  then
    sudo xcode-select --install
  fi
}

install_homebrew() {
  if ! command -v brew &> /dev/null
  then
      echo "installing homebrew"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

run_brew_install() {
  package_name=$1

  if ! command -v brew &> /dev/null
  then
      echo "brew is not installed"
      exit 1
  fi

  if brew list $1 &>/dev/null; then
    echo "already installed: $package_name"
  else
    echo "installing $package_name"
    brew install $package_name
  fi
}

install_zsh() {
  if ! command -v zsh &> /dev/null
  then
    echo "installing zsh"
    brew install zsh
  fi
}

install_git() {
  if ! command -v git &> /dev/null
  then
    echo "installing git"
    brew install git
  fi
}

install_tools() {
  echo "installing tools for macOS"
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

  install_tools:node
}

install_tools:node() {
  if ! command -v node &> /dev/null
  then
    echo "installing node"
    nvm_latest=$(curl -q -w "%{url_effective}\\n" -L -s -S https://latest.nvm.sh -o /dev/null)
    nvm_latest=${nvm_latest##*/}
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_latest}/install.sh" | bash
    [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
    nvm install --lts
    nvm use --lts
  fi
}

install_tools:argcomplete() {
  if ! command -v register-python-argcomplete &> /dev/null
  then
    echo "installing argcomplete"
    pip3 install argcomplete
  fi
}

symlink_if_not_exists() {
  src="$1"
  dest="$DOTFILE_DIR/dot/bin/$2"

  if [ ! -f "$dest" ] && [ -f "$src"] ; then
    echo "symlinking \"$src\" to \"$dest\""
    ln -s "$src" "$dest"
  fi
}

create_bin() {
  if [ ! -d "$DOTFILE_DIR/dot/bin" ]
  then
    echo "creating $DOTFILE_DIR/dot/bin"
    mkdir $DOTFILE_DIR/dot/bin
  fi

  if [ ! -f "$DOTFILE_DIR/dot/bin/chrome" ]; then
    cat > "$DOTFILE_DIR/dot/bin/chrome" << EOT
#!/usr/bin/env zsh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "$@"
EOT
  fi
  chmod +x "$DOTFILE_DIR/dot/bin/chrome"
  ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "$DOTFILE_DIR/dot/bin/code"
}

install_dmg() {
  package_name="$1"
  url="$2"
  check_file="$3"

  if [ ! -f "$check_file" ]; then
    echo "installing $package_name"
    curl -sL -o "/tmp/$package_name.dmg" "$url"
    dir=$(hdiutil attach -nobrowse "/tmp/$package_name.dmg" | tail -1 | sed 's/.*Volumes\///')
    cp -r "/Volumes/$dir/$package_name.app" /Applications
    hdiutil detach -quiet "/Volumes/$package_name"
    rm "/tmp/$package_name.dmg"
  fi
}

install_zip() {
  package_name="$1"
  url="$2"
  check_file="$3"

  if [ ! -f "$check_file" ]; then
    echo "installing $package_name"
    curl -sL -o "/tmp/$package_name.zip" "$url"
    unzip -q "/tmp/$package_name.zip" -d /Applications
    rm "/tmp/$package_name.zip"
  fi
}

install_pkg() {
  package_name="$1"
  url="$2"
  check_file="$3"

  if [ ! -f "$check_file" ]; then
    echo "installing $package_name"
    curl -sL -o "/tmp/$package_name.pkg" "$url"
    sudo installer -pkg "/tmp/$package_name.pkg" -target /
    rm "/tmp/$package_name.pkg"
  fi
}

install_software() {
  echo "installing software for macOS"

  arch=$(uname -m)

  if [ "$arch" = "arm64" ]; then
    vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=darwin-arm64"
    notion_url="https://www.notion.so/desktop/apple-silicon/download"
    zoom_url="https://zoom.us/client/latest/Zoom.pkg"
    docker_url="https://desktop.docker.com/mac/stable/arm64/Docker.dmg"
  else
    vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=darwin"
    notion_url="https://www.notion.so/desktop/mac/download"
    zoom_url="https://zoom.us/client/latest/Zoom.pkg?archType=arm64"
    docker_url="https://desktop.docker.com/mac/stable/amd64/Docker.dmg"
  fi

  install_dmg "Google Chrome" "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  install_zip "Visual Studio Code" "$vscode_url" "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
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

  install_pkg "zoom.us" "$zoom_url" "/Applications/zoom.us.app/Contents/MacOS/zoom.us"
  install_dmg "Docker" "$docker_url" "/Applications/Docker.app/Contents/MacOS/Docker"

  create_bin
}
