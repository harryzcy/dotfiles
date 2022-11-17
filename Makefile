.PHONY: setup test upgrade

setup:
	./script/setup.sh

test:
	./test/test.sh

upgrade:
	./command/upgrade.sh

clean:
	./command/clean.sh
