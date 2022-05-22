# .functions_docker.zsh
# Functions related to docker operations

docker_prune() {
  docker system prune -a
}
