# dot command

dot() {
  command="$1"
  if [ -z "$command" ]; then
    echo "dot: no command specified"
    return 1
  fi

  if [ ${command} = "clean" ]; then
    ${DOTFILE_DIR}/script/clean.sh
  elif [ ${command} = "update" ]; then
    git -C ${DOTFILE_DIR} pull
  elif [ ${command} = "upgrade" ]; then
    ${DOTFILE_DIR}/script/upgrade.sh
  elif [ ${command} = "reload" ]; then
    source ~/.zshrc
  else
    echo "dot: unknown command"
    return 1
  fi
}
