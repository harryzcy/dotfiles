# dot command

# run a command, appending its output to ~/.dot/dot.log under a timestamped header
_dot_log() {
  setopt localoptions pipefail
  local log_file="$HOME/.dot/dot.log"
  local label="$1"
  shift
  mkdir -p "${log_file:h}"
  print -r -- "==> $(date '+%Y-%m-%d %H:%M:%S') dot $label" >> "$log_file"
  "$@" 2>&1 | tee -a "$log_file"
}

dot() {
  command="$1"
  if [ -z "$command" ]; then
    echo "dot: command utility"
    echo
    echo "Usage: dot <command> [options]"
    echo
    echo "Commands:"
    echo "  clean   clean up cache"
    echo "  clone   clone repositories"
    echo "  code    open repository in VSCode"
    echo "  goto    goto repository"
    echo "  lookup  lookup oh-my-zsh plugins"
    echo "  pull    pull repositories"
    echo "  reload  reload dotfiles"
    echo "  repo    print repository path"
    echo "  tm      time machine utilities"
    echo "  update  update dotfiles from Git"
    echo "  upgrade upgrade installed packages"
    return 1
  fi
  shift

  if [ ${command} = "clean" ]; then
    _dot_log clean ${DOTFILE_DIR}/script/clean.sh
  elif [ ${command} = "clone" ]; then
    _dot_log clone ${DOTFILE_DIR}/script/clone.sh
  elif [ ${command} = "update" ]; then
    _dot_log update git -C ${DOTFILE_DIR} pull
  elif [ ${command} = "upgrade" ]; then
    _dot_log upgrade ${DOTFILE_DIR}/script/upgrade.sh
  elif [ ${command} = "reload" ]; then
    source ~/.zshrc
  elif [ ${command} = "repo" ]; then
    ${DOTFILE_DIR}/script/repo.sh "$@"
  elif [ ${command} = "goto" ]; then
    dir=$(${DOTFILE_DIR}/script/repo.sh "$@")
    if [ -z "$dir" ]; then
      echo "dot: repository not found"
      return 1
    fi
    cd $dir
  elif [ ${command} = "code" ]; then
    dir=$(${DOTFILE_DIR}/script/repo.sh "$@")
    if [ -z "$dir" ]; then
      echo "dot: repository not found"
      return 1
    fi
    code $dir
  elif [ ${command} = "tm" ]; then
    ${DOTFILE_DIR}/script/tm.sh "$@"
  elif [ ${command} = "pull" ]; then
    _dot_log pull ${DOTFILE_DIR}/script/pull.sh
  elif [ ${command} = "lookup" ]; then
    ${DOTFILE_DIR}/script/lookup.sh "$@"
  else
    echo "dot: unknown command"
    return 1
  fi
}
