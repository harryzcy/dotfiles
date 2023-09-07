#compdef dot

_dot() {
  local -a subcmds
  subcmds=('clean' 'update' 'upgrade' 'reload' 'repo' 'goto' 'code' 'tm')
  _describe 'command' subcmds
}

# don't run the completion function when being source-ed or eval-ed
if [ "$funcstack[1]" = "_dot" ]; then
  _dot
fi

compdef _dot dot
