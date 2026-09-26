#compdef dot

_dot() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -C \
    '1: :->command' \
    '*:: :->args'

  case $state in
    command)
      local -a subcmds
      subcmds=(
        'clean:clean up cache'
        'clone:clone repositories'
        'update:update dotfiles from Git'
        'upgrade:upgrade installed packages'
        'reload:reload dotfiles'
        'repo:print repository path'
        'goto:goto repository'
        'code:open repository in VSCode'
        'tm:time machine utilities'
        'pull:pull repositories'
        'lookup:lookup oh-my-zsh plugins'
      )
      _describe 'command' subcmds
      ;;
    args)
      # words[1] is the subcommand here
      case $words[1] in
        repo|goto|code)
          (( CURRENT == 2 )) || return
          local -a repo_dirs
          repo_dirs=(${(s.:.)DOT_REPO_PATH})
          _alternative \
            'repositories:repository:_path_files -/ -W repo_dirs' \
            'current:current directory:(.)'
          ;;
        tm)
          if (( CURRENT == 2 )); then
            local -a tm_cmds
            tm_cmds=(
              'ls:list excluded items'
              'add:exclude a path, or auto-exclude the current directory'
              'rm:remove an exclusion'
              'check:check whether a path is excluded'
            )
            _describe 'tm command' tm_cmds
          elif (( CURRENT == 3 )); then
            case $words[2] in
              add) _alternative 'flags:flag:(--dry-run)' 'paths:path:_files' ;;
              rm|check) _files ;;
            esac
          fi
          ;;
        lookup)
          (( CURRENT == 2 )) || return
          local -a plugins
          plugins=($ZSH/plugins/*(N/:t))
          _describe 'oh-my-zsh plugin' plugins
          ;;
      esac
      ;;
  esac
}

# don't run the completion function when being source-ed or eval-ed
if [ "$funcstack[1]" = "_dot" ]; then
  _dot
fi

compdef _dot dot
