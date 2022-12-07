.PHONY: setup test upgrade

setup:
  echo $(value GITHUB_TOKEN)
	./script/setup.sh

test:
	./test/test.sh

upgrade:
	./script/upgrade.sh

clean:
	./script/clean.sh
