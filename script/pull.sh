#!/usr/bin/env zsh

source "$DOTFILE_DIR/script/misc/repo.sh"

for repo in $repositories; do
  echo "Pulling $repo..."
  repo_path="$PROJECTS_PATH/$repo"
  if [[ -d "$repo_path" ]]; then
    # only pull main branch
    branch=$(git -C "$repo_path" branch --show-current)
    echo $branch
    if [ ${branch} = "main" ]; then
      git -C "$repo_path" pull
      git -C "$repo_path" fetch --all --prune
    fi
    echo
  fi
done
