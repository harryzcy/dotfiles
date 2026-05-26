#!/usr/bin/env zsh

plugins_url="https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/"

if [[ $# -eq 0 ]]; then
  echo "Usage: dot lookup <plugin>"
  return 1
fi

plugin="$1"
if [[ -z "$plugin" ]]; then
  echo "Usage: dot lookup <plugin>"
  return 1
fi

echo "Looking up plugin '$plugin'..."
open "${plugins_url}${plugin}"
