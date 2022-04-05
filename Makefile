.PHONY: setup test load

setup:
	./setup/setup.sh

test:
	./test/test.sh

load:
	source ~/.zshrc
