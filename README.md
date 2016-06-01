stbt-docker
===========

Copyright (c) 2015-2016 stb-tester.com Ltd.

stbt-docker is released under the [MIT License].

stbt-docker runs the specified command in a docker container that is set up
like an [stb-tester ONE] but without video-capture or infrared hardware.

The docker container will have stbt and all its dependencies installed,
as well as your test-pack's own dependencies as specified in
[config/setup/setup]. This makes it easier to run stbt commands on a CI server
or on a developer's PC for local test-script development, when video-capture
is not needed: For example to run pylint, stbt auto-selftest, etc.

Run this command from an stb-tester [test-pack]. The test-pack will be mounted
into the docker container as "/var/lib/stbt/test-pack".

Usage
-----

    $ ./stbt-docker stbt lint --errors-only tests/roku.py
    ********** module roku
    E:284,12: "wait_until" return value not used (missing "assert"?) (stbt-unused-return-value)

    $ ./stbt-docker python -m doctest tests/roku.py
    ...

    $ ./stbt-docker python
    Python 2.7.6 (default, Jun 22 2015, 17:58:13)
    [GCC 4.8.2] on linux2
    Type "help", "copyright", "credits" or "license" for more information.
    >>> import stbt
    >>> stbt.match(...)

    $ ./stbt-docker bash
    stb-tester@97f85a1a4eea:~/test-pack$ ...

Environment variables:

* DOCKER - The location of the docker binary. Defaults to "docker".
* DOCKER_OPTS - Additional arguments to "docker run". Shell escaping will be
  unescaped once, so that you can specify arguments with spaces. For example:
  DOCKER_OPTS="--memory=2g --volume=/path\ with\ spaces\ on\ host:/path\ in\ container"

Distribution & installation
---------------------------

stbt-docker is part of stb-tester but it is intended to be distributed
independently, checked into test-packs. The canonical source is
<https://github.com/stb-tester/stbt-docker>.

To install, copy stbt-docker to the root of your test-pack. To upgrade,
just download a new version of stbt-docker from this git repository.

stbt-docker is built with portability in mind so it should run on Mac OS and
Windows. The only dependencies are Python and Docker. stbt-docker is
self-contained and relocatable so it can be deployed as a single file with no
dependency on anything else in stbt.

stbt-docker development is done in its own git repository (instead of the
main stb-tester git repository) because stbt-docker has a different release
cycle (there will be a new release of stbt-docker for each [stb-tester ONE]
release, because stbt-docker depends on the docker images used on the
[stb-tester ONE]).


[MIT License]: https://github.com/stb-tester/stbt-docker/blob/master/LICENSE
[stb-tester ONE]: https://stb-tester.com/stb-tester-one
[config/setup/setup]: https://stb-tester.com/manual/advanced-configuration#customising-the-test-run-environment
[test-pack]: https://github.com/stb-tester/stb-tester-test-pack
