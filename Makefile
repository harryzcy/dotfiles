.PHONY: setup test upgrade token

setup: token
	./script/setup.sh

token:
	@echo $(value GITHUB_TOKEN)

test:
	./test/test.sh

upgrade:
	./script/upgrade.sh

clean:
	./script/clean.sh
