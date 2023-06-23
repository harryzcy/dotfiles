#!/usr/bin/env zsh

arg=$1

directories=(
  node_modules
)

auto_exclude() {
  flag=$1
  dry_run=false
  if [ "$flag" = "--dry-run" ]; then
    dry_run=true
  fi

  excluded=()

  for dir in $PWD/**/*/; do
    dir="${dir:a}" # remote trailing slash

    # check if dir is already excluded
    for exclude in $excluded; do
      if [[ $dir =~ $exclude ]]; then
        continue 2
      fi
    done

    # check if dir matches any of the excluded directories
    for exclude in $directories; do
      if [[ $dir =~ $exclude ]]; then
        if [ "$dry_run" = true ]; then
          echo "Would exclude $dir"
        else
          echo "Excluding $dir"
          # tmutil addexclusion $dir
        fi
        excluded+=($dir)
      fi
    done
  done
}

add_exclude() {
  if [ -z "$1" ]; then
    echo "tm: no path specified"
    return 1
  fi

  dir=$1
  echo "Excluding $dir"
  tmutil addexclusion $dir
}

auto_remote_exclude() {

}

remove_exclude() {
  if [ -z "$1" ]; then
    echo "tm: no path specified"
    return 1
  fi

  dir=$1
  echo "Removing $dir"
  tmutil removeexclusion $dir
}

if [ -z "$arg" ]; then
  echo "tm: no command specified"

  echo "Usage:"
  echo "  tm ls"
  echo "  tm add [path]"
  echo "  tm rm [path]"
  echo "  tm check [path]"
  return 1
fi

if [ "$arg" = "ls" ]; then
  sudo mdfind "com_apple_backup_excludeItem = 'com.apple.backupd'"
elif [ "$arg" = "add" ]; then
  if [ -z "$2" ]; then
    auto_exclude
  else
    add_exclude $2
  fi
elif [ "$arg" = "rm" ]; then
  if [ -z "$2" ]; then
    auto_remote_exclude
  else
    remove_exclude $2
  fi
elif [ "$arg" = "check" ]; then
  tmutil isexcluded $2
else
  echo "tm: unknown command"
  return 1
fi
