# general
alias c='clear'
alias r='reload'
alias reload='source ~/.zshrc'

# ansible
alias a='ansible'
alias ap='ansible-playbook'

# dot
alias tm='dot tm'
alias goto='dot goto'
alias reload='dot reload'
alias repo='dot repo'
alias clone='dot clone'
alias cl='dot clone'
alias pull='dot pull'
alias pl='dot pull'

# gh
alias ghp='gh pr'
alias ghpc='gh pr create'
alias ghpw='gh pr view --web'
alias ghpco='gh pr checkout'
alias ghps='gh pr status'
alias ghauto='gh pr merge --auto'
alias ghr='gh repo'
alias ghrc='gh repo clone'

# git
# git_main_branch is used by git plugin for `gcm` alias
git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  default_branch=$(command git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@' 2>/dev/null)
  echo ${default_branch:-main}
}

gfaa() {
  fetch_all_out=$(gfa)
  echo "$fetch_all_out"
}

# kubectl
alias kak="kubectl apply -k"
