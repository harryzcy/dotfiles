#!/usr/bin/env zsh

repositories=(
  act-images
  action-bark
  docker-sally
  harryzcy.github.io
  mailbox
  mailbox-browser
  mailbox-cli
  notion-cli
)

for repo in $repositories; do
  echo "Pulling $repo..."
  repo_path="$PROJECTS_PATH/$repo"
  if [[ -d "$repo_path" ]]; then
    # only pull main branch
    branch=$(git -C "$repo_path" branch --show-current)
    echo $branch
    if [ ${branch} = "main" ]; then
      git -C "$repo_path" pull
    fi
    echo
  fi
done
