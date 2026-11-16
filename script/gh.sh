#!/usr/bin/env zsh

api_version="2026-03-10"

# global so the signal and exit traps can reach them
_tmp_dir=""
_bg_pids=()
_worker_pid=""
_queue_fd=""

_gh_api() {
  gh api -H "X-GitHub-Api-Version: $api_version" "$@"
}

_cleanup() {
  ((${#_bg_pids})) && kill $_bg_pids 2>/dev/null
  [ -n "$_worker_pid" ] && kill -TERM $_worker_pid 2>/dev/null
  [ -n "$_tmp_dir" ] && rm -rf "$_tmp_dir"
}

# on Ctrl-C, drop anything still queued, but let an in-flight request finish
_interrupt() {
  echo
  ((${#_bg_pids})) && kill $_bg_pids 2>/dev/null
  _bg_pids=()
  if [ -n "$_worker_pid" ]; then
    echo "Cancelling, letting the in-flight request finish..."
    kill -TERM $_worker_pid 2>/dev/null
    [ -n "$_queue_fd" ] && exec {_queue_fd}>&-
    wait $_worker_pid 2>/dev/null
    _worker_pid=""
  fi
  if [ -f "$_tmp_dir/done" ]; then
    echo "Cancelled; $(wc -l <"$_tmp_dir/done" | tr -d ' ') notification(s) marked done"
  else
    echo "Cancelled"
  fi
  exit 130
}

trap _cleanup EXIT
trap _interrupt INT TERM

# mark notifications for merged pull requests as done, asking per repository
mark_merged_done() {
  local dry_run=false assume_yes=false arg
  for arg in "$@"; do
    case "$arg" in
      --dry-run) dry_run=true ;;
      -y | --yes) assume_yes=true ;;
      *)
        echo "gh done: unknown option '$arg'"
        return 1
        ;;
    esac
  done

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

  # keep temp files under a dot/ prefix so leftovers are easy to trace
  local tmp_root="${TMPDIR:-/tmp}/dot"
  mkdir -p -m 700 "$tmp_root" || return 1
  _tmp_dir=$(mktemp -d "$tmp_root/gh.XXXXXX") || return 1

  # look up merge state in parallel batches with GraphQL instead of one request per PR
  local i j query
  for ((i = 1; i <= $#ids; i += 50)); do
    query="query {"
    for ((j = i; j < i + 50 && j <= $#ids; j++)); do
      query+=" p$j: repository(owner: \"${repos[j]%%/*}\", name: \"${repos[j]#*/}\") { pullRequest(number: ${numbers[j]}) { merged } }"
    done
    query+=" }"
    gh api graphql -f query="$query" \
      --jq '.data | to_entries[] | select(.value.pullRequest.merged) | .key | ltrimstr("p")' \
      >"$_tmp_dir/merged.$i" 2>/dev/null &
    _bg_pids+=($!)
  done
  wait
  _bg_pids=()
  local -a merged=($(cat "$_tmp_dir"/merged.*(N) | sort -n))

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

  # one background worker marks queued threads done, one at a time,
  # so the next repository can be reviewed meanwhile
  if [ "$dry_run" = false ]; then
    mkfifo "$_tmp_dir/queue" || return 1
    {
      # Ctrl-C reaches the whole process group; ignore it here (and in gh) and
      # let the main script stop this worker with TERM, which only takes effect
      # between requests so an in-flight one always finishes
      local stop=""
      trap - EXIT
      trap '' INT
      trap 'stop=1' TERM
      while [ -z "$stop" ] && read -r id; do
        _gh_api -X DELETE "notifications/threads/$id" --silent 2>/dev/null && echo "$id"
      done
    } <"$_tmp_dir/queue" >"$_tmp_dir/done" &
    _worker_pid=$!
    exec {_queue_fd}>"$_tmp_dir/queue"
  fi

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

    if [ "$assume_yes" = false ]; then
      if ! read -q "?Mark $#items notification(s) as done? [y/N] "; then
        echo
        continue
      fi
      echo
    fi
    count=$((count + $#items))
    for i in $items; do
      echo "${ids[i]}" >&$_queue_fd
    done
  done

  if [ "$dry_run" = true ]; then
    echo "$count notification(s) would be marked done"
    return 0
  fi

  # closing the queue lets the worker finish what is left, then exit
  exec {_queue_fd}>&-
  _queue_fd=""
  if ((count > 0)); then
    echo "Waiting for remaining notifications to be marked done... (Ctrl-C to cancel)"
  fi
  wait $_worker_pid
  _worker_pid=""
  local marked=$(wc -l <"$_tmp_dir/done" | tr -d ' ')
  echo "$marked notification(s) marked done"
  if ((marked < count)); then
    echo "$((count - marked)) failed, possibly due to GitHub's rate limit; run again to retry"
  fi
}

if [ -z "$1" ]; then
  echo "gh: no command specified"

  echo "Usage:"
  echo "  gh done [--dry-run] [-y|--yes]  mark notifications for merged pull requests as done"
  echo
  echo "Options:"
  echo "  --dry-run  list what would be marked done, without asking"
  echo "  -y, --yes  mark all without asking per repository"
  return 1
fi

if [ "$1" = "done" ]; then
  mark_merged_done "${@:2}"
else
  echo "gh: unknown command"
  return 1
fi
