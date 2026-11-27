# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  git
  web-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  asdf
  golang
  helm
  python
  pip
  terraform
  dotenv
  kubectl
)

platform_dir=$(dirname "$(realpath "$HOME/.zshrc")")
export DOTFILE_DIR="$(dirname "$platform_dir")"

# plugins skip loading if their command isn't on PATH yet
typeset -U path
path+=("$DOTFILE_DIR/dot/bin")

source $ZSH/oh-my-zsh.sh

# User configuration

export GPG_TTY=$(tty)

# load dot command
source "$DOTFILE_DIR/dot/dot.zsh"
source "$DOTFILE_DIR/dot/_dot.zsh"

source "$DOTFILE_DIR/shared/.functions.zsh"
source "$DOTFILE_DIR/shared/.environments.sh"

if [ -z "$DISPLAY" ]; then
  PROMPT="%{$fg[green]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%} ${PROMPT}"
fi

if [[ "$IS_DEV_MACHINE" = true ]]; then
  source $DOTFILE_DIR/linux/dev.environments.zsh
else
  export DOWNLOAD_DIR="$HOME"
fi

# warn about a pending reboot in terminals; VS Code also runs zsh in the
# background to read the environment, which must stay silent
if [[ -o interactive && -t 1 && -z "$VSCODE_RESOLVING_ENVIRONMENT" && -f /var/run/reboot-required ]]; then
  () {
    local -a pkgs
    [[ -r /var/run/reboot-required.pkgs ]] && pkgs=(${(fu)"$(</var/run/reboot-required.pkgs)"})
    print -P "%F{yellow}*** System restart required ***%f${pkgs:+ (${(j:, :)pkgs})}"
  }
fi

if [[ -f "$HOME/.zshrc.local" ]]; then
  source $HOME/.zshrc.local
fi
