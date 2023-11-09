#!/usr/bin/env bash

run_brew_install() {
  package_name=$1

  if ! command -v brew &>/dev/null; then
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
    curl -L -o "/tmp/$package_name.zip" "$url"
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
