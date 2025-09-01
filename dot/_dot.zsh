#compdef dot

_dot() {
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
  )
  _describe 'command' subcmds
}

# don't run the completion function when being source-ed or eval-ed
if [ "$funcstack[1]" = "_dot" ]; then
  _dot
fi

compdef _dot dot
