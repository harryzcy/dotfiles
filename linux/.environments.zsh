if [[ $(hostname -s) = gpu-* ]]; then
	eval "$(/home/harryzcy/miniconda3/bin/conda shell.zsh hook)"

	export DOT_REPO_PATH="${HOME}/Projects:${HOME}/Projects/telepresence"
fi
