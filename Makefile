# The default target of this Makefile is:
all:

.DELETE_ON_ERROR:

clean:
	git clean -Xfd || true

check: check-pylint check-integrationtests
check-integrationtests :
	tests/run-tests.sh tests/test-stbt-docker.sh
check-pylint:
	./pylint.sh stbt-docker

.PHONY: all clean check check-integrationtests check-pylint
.PHONY: FORCE
