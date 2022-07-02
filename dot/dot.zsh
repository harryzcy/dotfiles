# dot command

dot() {
  command="$1"
  if [ -z "$command" ]; then
    echo "dot: no command specified"
    return 1
  fi

  if [ ${command} = "clean" ]; then
    ${DOTFILE_DIR}/command/clean.sh
  elif [ ${command} = "upgrade" ]; then
    ${DOTFILE_DIR}/command/upgrade.sh
  elif [ ${command} = "reload" ]; then
    source ~/.zshrc
  else
    echo "dot: unknown command"
    return 1
  fi
}
