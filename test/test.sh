#!/usr/bin/env zsh

check_command() {
  if ! command -v $1 &> /dev/null
  then
    echo "command $1 could not be found"
    exit 1
  fi
}

check_file() {
  if [[ ! -f $1 ]]; then
    echo "file $1 could not be found"
    exit 1
  fi
}

check_directory() {
  if [[ ! -d $1 ]]; then
    echo "directory $1 could not be found"
    exit 1
  fi
}

check_sym_link() {
  if [[ ! -L $1 ]]; then
    echo "symbolic link $1 could not be found"
    exit 1
  fi
  if [[ ! -e $1 ]]; then
    echo "symbolic link $1 is broken"
    exit 1
  fi
}

# change to the directory of this script
current=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd ${current}

base_dir=$(dirname ${current})

source ./test_common.sh

# detect the operating system
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  source ./test_linux.sh
elif [[ "$unamestr" == 'Darwin' ]]; then
  source ./test_darwin.sh
else
  echo "unsupported platform: $platform"
  exit 1
fi

check_git && echo "git is installed"
check_zsh && echo "zsh is installed"
check_tools && echo "tools are installed"
check_softwares && echo "softwares are installed"
