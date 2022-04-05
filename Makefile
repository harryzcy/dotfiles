.PHONY: setup test

setup:
	./setup/setup.sh

test:
	zsh ./test/test.sh
