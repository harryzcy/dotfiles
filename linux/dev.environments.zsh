path=(
	/usr/local/go/bin # Go
	$path
	$GOPATH/bin # Go
)
export PATH

eval "$(/home/harryzcy/miniconda3/bin/conda shell.zsh hook)"

export DOT_REPO_PATH="${HOME}/Projects:${HOME}/Projects/telepresence"