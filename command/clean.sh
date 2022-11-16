#!/bin/bash

clean:mac() {
  brew cleanup -s

  # clean pip cache
  local_wheel_str=$(pip3 cache info | grep "locally built wheels")
  num_wheels=${local_wheel_str#*:} # remove everything before :
  if (( num_wheels > 0 )); then
    pip3 cache remove *
  fi
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
