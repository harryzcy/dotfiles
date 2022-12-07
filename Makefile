.PHONY: setup test upgrade

setup:
	./script/setup.sh

test:
	./test/test.sh

upgrade:
	./script/upgrade.sh

clean:
	./script/clean.sh
