#!/bin/zsh

repo_name=$1

(
  if [ $ZSH_VERSION ]; then
    setopt sh_word_split
  fi

  IFS=:
  for p in $DOT_REPO_PATH; do
    full_path="${p}/${repo_name}"
    if [ -d "${full_path}" ]; then
      echo "${full_path}"
      return
    fi
  done
)
