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

publish-test-docker-container:
	docker build -t stbtester/stbt-docker-selftest tests/
	docker push stbtester/stbt-docker-selftest

.PHONY: all clean check check-integrationtests check-pylint
.PHONY: FORCE
