#!/usr/bin/env zsh

# Temp files live in ${TMPDIR:-/tmp}/dot/gh.XXXXXX/, removed on exit and on Ctrl-C:
#   merged.N    merged PRs found by each GraphQL batch
#   queue       FIFO of thread IDs for the background worker
#   done        thread IDs marked done
#   worker.log  worker's log, printed between prompts

zmodload zsh/datetime

api_version="2026-03-10"

# global so the signal and exit traps can reach them
_tmp_dir=""
_bg_pids=()
_worker_pid=""
_queue_fd=""

_verbose=false

# _gh_api METHOD ENDPOINT [gh api options...]; set _label to annotate the log line
# failed requests are always logged, and every request with --verbose
_gh_api() {
  local method=$1 endpoint=$2 start=$EPOCHREALTIME rc
  shift 2
  gh api -X "$method" -H "X-GitHub-Api-Version: $api_version" "$endpoint" "$@"
  rc=$?
  if ((rc != 0)) || [ "$_verbose" = true ]; then
    printf '[gh] %s %s%s -> %s (%.2fs)\n' "$method" "$endpoint" "${_label:+ ($_label)}" \
      "$( ((rc == 0)) && echo ok || echo "failed, exit $rc")" $((EPOCHREALTIME - start)) >&2
  fi
  return $rc
}

# the worker logs to a file, printed between prompts so it doesn't land on a prompt line
_log_lines=0
_flush_worker_log() {
  local log="$_tmp_dir/worker.log" total
  [ -f "$log" ] || return 0
  total=$(wc -l <"$log" | tr -d ' ')
  ((total > _log_lines)) || return 0
  # stop at the last complete line, in case the worker is mid-write
  tail -n +$((_log_lines + 1)) "$log" | head -n $((total - _log_lines)) >&2
  _log_lines=$total
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
    _flush_worker_log
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

mark_merged_done() {
  local dry_run=false assume_yes=false arg
  for arg in "$@"; do
    case "$arg" in
      --dry-run) dry_run=true ;;
      -y | --yes) assume_yes=true ;;
      -v | --verbose) _verbose=true ;;
      *)
        echo "gh done: unknown option '$arg'"
        return 1
        ;;
    esac
  done

  # paged by hand so verbose logs each page; without is_done=false, all=true
  # also returns notifications already marked done
  local -a ids repos numbers titles
  local id type url repo title rows page=1 n
  while :; do
    rows=$(_gh_api GET "notifications?all=true&is_done=false&per_page=50&page=$page" \
      --jq '.[] | [.id, .subject.type, .subject.url, .repository.full_name, .subject.title] | @tsv') || return 1
    n=0
    while IFS=$'\t' read -r id type url repo title; do
      [ -z "$id" ] && continue
      n=$((n + 1))
      [ "$type" = "PullRequest" ] || continue
      # read collapses empty tab-separated fields, so a missing URL shifts the rest
      [[ "$url" == */pulls/<-> ]] || continue
      ids+=("$id")
      repos+=("$repo")
      numbers+=("${url##*/}")
      titles+=("$title")
    done <<<"$rows"
    ((n < 50)) && break
    page=$((page + 1))
  done

  local tmp_root="${TMPDIR:-/tmp}/dot"
  mkdir -p -m 700 "$tmp_root" || return 1
  _tmp_dir=$(mktemp -d "$tmp_root/gh.XXXXXX") || return 1

  # one PR erroring (e.g. a deleted repo) makes gh exit 1 and skip --jq,
  # so parse the partial data with jq instead
  local i j query
  for ((i = 1; i <= $#ids; i += 50)); do
    query="query {"
    for ((j = i; j < i + 50 && j <= $#ids; j++)); do
      query+=" p$j: repository(owner: \"${repos[j]%%/*}\", name: \"${repos[j]#*/}\") { pullRequest(number: ${numbers[j]}) { merged } }"
    done
    query+=" }"
    _label="PRs $i-$((j - 1))" _gh_api POST graphql -f query="$query" |
      jq -r '.data // {} | to_entries[] | select(.value.pullRequest.merged == true) | .key | ltrimstr("p")' \
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

  local -a repo_order
  local -A repo_items
  for i in $merged; do
    repo=${repos[i]}
    (( ${+repo_items[$repo]} )) || repo_order+=("$repo")
    repo_items[$repo]+=" $i"
  done

  # a background worker marks queued threads done while the next repository is reviewed
  if [ "$dry_run" = false ]; then
    mkfifo "$_tmp_dir/queue" || return 1
    {
      # Ctrl-C reaches the whole process group, so ignore it here (and in gh);
      # the main script stops the worker with TERM, checked between requests
      local stop=""
      trap - EXIT
      trap '' INT
      trap 'stop=1' TERM
      while [ -z "$stop" ] && read -r id; do
        _gh_api DELETE "notifications/threads/$id" --silent && echo "$id"
      done
    } <"$_tmp_dir/queue" >"$_tmp_dir/done" 2>"$_tmp_dir/worker.log" &
    _worker_pid=$!
    exec {_queue_fd}>"$_tmp_dir/queue"
  fi

  local count=0
  for repo in $repo_order; do
    local -a items=(${=repo_items[$repo]})
    _flush_worker_log
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

  # closing the queue lets the worker drain it, then exit
  exec {_queue_fd}>&-
  _queue_fd=""
  if ((count > 0)); then
    echo "Waiting for remaining notifications to be marked done... (Ctrl-C to cancel)"
  fi
  while kill -0 $_worker_pid 2>/dev/null; do
    _flush_worker_log
    sleep 0.2
  done
  wait $_worker_pid
  _worker_pid=""
  _flush_worker_log
  local marked=$(wc -l <"$_tmp_dir/done" | tr -d ' ')
  echo "$marked notification(s) marked done"
  if ((marked < count)); then
    echo "$((count - marked)) failed; run again to retry"
    return 1
  fi
}

if [ -z "$1" ]; then
  echo "gh: no command specified"

  echo "Usage:"
  echo "  gh done [--dry-run] [-y|--yes] [-v|--verbose]  mark notifications for merged pull requests as done"
  echo
  echo "Options:"
  echo "  --dry-run      list what would be marked done, without asking"
  echo "  -y, --yes      mark all without asking per repository"
  echo "  -v, --verbose  print each API request"
  return 1
fi

if [ "$1" = "done" ]; then
  mark_merged_done "${@:2}"
else
  echo "gh: unknown command"
  return 1
fi
