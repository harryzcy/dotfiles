.PHONY: setup test load upgrade

setup:
	./setup/setup.sh

test:
	./test/test.sh

load:
	source ~/.zshrc

upgrade:
	zsh ./command/upgrade.sh

clean:
	./command/clean.sh
