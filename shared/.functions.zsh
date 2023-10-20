# .functions.zsh
# shared functions for all platforms

source $DOTFILE_DIR/shared/.functions_go.zsh
source $DOTFILE_DIR/shared/.functions.sh

docker_prune() {
  docker system prune -a
}
