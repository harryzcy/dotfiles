.PHONY: setup
setup:
	./script/setup.sh
.PHONY: test
test:
	./test/test.sh
.PHONY: test-unit
test-unit:
	bats test/unit
