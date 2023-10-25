#!/usr/bin/env zsh

clean:mac() {
  brew cleanup

  # clean pip cache
  local_wheel_str=$(pip3 cache info | grep "locally built wheels")
  num_wheels=${local_wheel_str#*:} # remove everything before :
  if ((num_wheels > 0)); then
    pip3 cache remove "*"
  fi
}

clean:debian() {
  sudo apt-get autoremove -y
  sudo apt-get autoclean -y
  sudo apt-get clean -y
}

source ${DOTFILE_DIR}/shared/.functions.sh
os=$(detect_os)
if [[ "$os" == 'linux' ]]; then
  clean:debian
elif [[ "$os" == 'macos' ]]; then
  clean:mac
fi
