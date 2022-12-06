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
  executable_name=${2:-$package_name}

  if ! command -v brew &> /dev/null
  then
      echo "brew is not installed"
      exit 1
  fi

  if ! command -v $executable_name &> /dev/null
  then
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
  run_brew_install coreutils realpath
  run_brew_install cloc
  run_brew_install curl
  run_brew_install gh
  run_brew_install httpie
  run_brew_install jq
  run_brew_install python3
  run_brew_install tree
  run_brew_install wget
  run_brew_install gnupg gpg

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

symlink_if_not_exists() {
  src="$1"
  dest="$DOTFILE_DIR/dot/bin/$2"

  if [ ! -f "$dest" ] && [ -f "$src"] ; then
    echo "symlinking \"$src\" to \"$dest\""
    ln -s "$src" "$dest"
  fi
}

create_bin() {
  echo "$DOTFILE_DIR/dot/bin"
  if [ ! -d "$DOTFILE_DIR/dot/bin" ]
  then
    echo "creating $DOTFILE_DIR/dot/bin"
    mkdir $DOTFILE_DIR/dot/bin
  fi

  ls "$DOTFILE_DIR/dot/bin"

  if [ ! -f "$DOTFILE_DIR/dot/bin/chrome" ]; then
    cat > "$DOTFILE_DIR/dot/bin/chrome" << EOT
#!/usr/bin/env zsh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "$@"
EOT
  fi
  chmod +x "$DOTFILE_DIR/dot/bin/chrome"
}

install_dmg() {
  package_name="$1"
  url="$2"
  check_file="$3"

  if [ ! -f "$check_file" ]; then
    echo "installing $package_name"
    curl -L -o "/tmp/$package_name.dmg" "$url"
    hdiutil attach -nobrowse -quiet "/tmp/$package_name.dmg"
    cp -r "/Volumes/$package_name/$package_name.app" /Applications
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
    curl -L -o "/tmp/$package_name.zip" "$url"
    unzip -q "/tmp/$package_name.zip" -d /Applications
    rm "/tmp/$package_name.zip"
  fi
}

install_software() {
  echo "installing software for macOS"

  arch=$(uname -m)

  if [ "$arch" = "arm64" ]; then
    vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=darwin-arm64"
  else
    vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=darwin"
  fi

  install_dmg "Google Chrome" "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  install_zip "Visual Studio Code" "$vscode_url" "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"

  create_bin
}
