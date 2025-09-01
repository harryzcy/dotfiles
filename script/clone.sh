#!/usr/bin/env zsh

source "$DOTFILE_DIR/script/misc/repo.sh"

for repo in $repositories; do
  echo "Cloning $repo..."
  repo_path="$PROJECTS_PATH/$repo"
  if [[ ! -d "$repo_path" ]]; then
    gh repo clone "harryzcy/$repo" "$repo_path"
  fi
done
