#!/usr/bin/env zsh

api_version="2026-03-10"

_gh_api() {
  gh api -H "X-GitHub-Api-Version: $api_version" "$@"
}

# mark notifications for merged pull requests as done, asking per repository
mark_merged_done() {
  local dry_run=false
  if [ "$1" = "--dry-run" ]; then
    dry_run=true
  fi

  local -a ids repos numbers titles
  local id url repo title
  while IFS=$'\t' read -r id url repo title; do
    [ -z "$id" ] && continue
    ids+=("$id")
    repos+=("$repo")
    numbers+=("${url##*/}")
    titles+=("$title")
  done < <(_gh_api --paginate 'notifications?all=true&per_page=50' \
    --jq '.[] | select(.subject.type == "PullRequest") | [.id, .subject.url, .repository.full_name, .subject.title] | @tsv')

  # look up merge state in batches with GraphQL instead of one request per PR
  local -a merged
  local i j query
  for ((i = 1; i <= $#ids; i += 50)); do
    query="query {"
    for ((j = i; j < i + 50 && j <= $#ids; j++)); do
      query+=" p$j: repository(owner: \"${repos[j]%%/*}\", name: \"${repos[j]#*/}\") { pullRequest(number: ${numbers[j]}) { merged } }"
    done
    query+=" }"
    merged+=($(gh api graphql -f query="$query" \
      --jq '.data | to_entries[] | select(.value.pullRequest.merged) | .key | ltrimstr("p")' 2>/dev/null))
  done

  if [ $#merged -eq 0 ]; then
    echo "No notifications for merged pull requests"
    return 0
  fi

  # group by repository, keeping notification order
  local -a repo_order
  local -A repo_items
  for i in $merged; do
    repo=${repos[i]}
    (( ${+repo_items[$repo]} )) || repo_order+=("$repo")
    repo_items[$repo]+=" $i"
  done

  local count=0
  for repo in $repo_order; do
    local -a items=(${=repo_items[$repo]})
    echo "$repo:"
    for i in $items; do
      echo "  #${numbers[i]} ${titles[i]}"
    done

    if [ "$dry_run" = true ]; then
      count=$((count + $#items))
      continue
    fi

    if ! read -q "?Mark $#items notification(s) as done? [y/N] "; then
      echo
      continue
    fi
    echo
    for i in $items; do
      _gh_api -X DELETE "notifications/threads/${ids[i]}" >/dev/null && count=$((count + 1))
    done
  done

  if [ "$dry_run" = true ]; then
    echo "$count notification(s) would be marked done"
  else
    echo "$count notification(s) marked done"
  fi
}

if [ -z "$1" ]; then
  echo "gh: no command specified"

  echo "Usage:"
  echo "  gh done [--dry-run]  mark notifications for merged pull requests as done"
  return 1
fi

if [ "$1" = "done" ]; then
  mark_merged_done $2
else
  echo "gh: unknown command"
  return 1
fi
