.PHONY: setup test upgrade

setup:
	./setup/setup.sh

test:
	./test/test.sh

upgrade:
	./command/upgrade.sh

clean:
	./command/clean.sh
