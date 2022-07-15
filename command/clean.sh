#!/bin/bash

clean:mac() {
  brew cleanup -s
}

clean:debian() {
  apt-get autoremove -y
  apt-get autoclean -y
  apt-get clean -y
}

unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  # linux
  clean:debian
elif [[ "$unamestr" == 'Darwin' ]]; then
  # macos
  clean:mac
fi
