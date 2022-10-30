#!/bin/bash

clean:mac() {
  brew cleanup -s
}

clean:debian() {
  sudo apt-get autoremove -y
  sudo apt-get autoclean -y
  sudo apt-get clean -y
}

unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  # linux
  clean:debian
elif [[ "$unamestr" == 'Darwin' ]]; then
  # macos
  clean:mac
fi
