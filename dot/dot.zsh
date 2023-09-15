# dot command

dot() {
  command="$1"
  if [ -z "$command" ]; then
    echo "dot: command utility"
    echo
    echo "Usage: dot <command> [options]"
    echo
    echo "Commands:"
    echo "  clean   clean up cache"
    echo "  update  update dotfiles from Git"
    echo "  upgrade upgrade installed packages"
    echo "  reload  reload dotfiles"
    echo "  repo    print repository path"
    echo "  goto    goto repository"
    echo "  tm      time machine utilities"
    return 1
  fi
  shift

  if [ ${command} = "clean" ]; then
    ${DOTFILE_DIR}/script/clean.sh
  elif [ ${command} = "update" ]; then
    git -C ${DOTFILE_DIR} pull
  elif [ ${command} = "upgrade" ]; then
    ${DOTFILE_DIR}/script/upgrade.sh
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
  else
    echo "dot: unknown command"
    return 1
  fi
}
