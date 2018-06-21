# Run with ./run-tests.sh

load_test_pack() {
    if [ -n "$2" ]; then
        outdir=$2
    else
        outdir=.
    fi

    mkdir -p "$outdir"
    cp -r "$testdir/test-packs/$1" "$outdir" &&
    cd "$outdir/$1" || fail "Loading test pack $1 failed"
}

test_stbt_docker_fails_with_no_test_pack() {
    ! "$srcdir"/stbt-docker true || fail
}

test_stbt_docker_exec_runs_command_with_no_setup_script() {
    load_test_pack empty-test-pack
    "$srcdir"/stbt-docker echo -n hello >output || fail "Command should have succeeded"

    [ "$(cat output)" = "hello" ] || fail "Command not run"
}

test_stbt_docker_exec_runs_command_with_setup_script() {
    load_test_pack setup-script
    "$srcdir"/stbt-docker echo -n hello >output || fail "Command should have succeeded"

    [ "$(cat output)" = "hello" ] || fail "Command not run"
}

test_that_stbt_docker_exec_fails_with_bad_test_pack()
{
    load_test_pack bad-setup-script
    ! "$srcdir"/stbt-docker true || fail "Command should have failed"
}

test_your_files_are_available_in_stbt_docker() {
    load_test_pack empty-test-pack
    "$srcdir"/stbt-docker test -e config/stbt.conf || fail "Command should have succeeded"
}

test_that_path_within_container_is_same_as_outside() {
    load_test_pack empty-test-pack

    "$srcdir"/stbt-docker bash -c '[ $PWD = /var/lib/stbt/test-pack ]' \
    || fail "Directory doesnt match"

    cd config
    "$srcdir"/stbt-docker bash -c '[ $PWD = /var/lib/stbt/test-pack/config ]' \
    || fail "Directory doesnt match"
}

test_that_docker_opts_passes_arguments_through_to_docker_run() {
    load_test_pack empty-test-pack
    export DOCKER_OPTS="-e HELLO=goodbye\\ cruel\\ world"
    "$srcdir"/stbt-docker bash -c 'echo -e $HELLO >output'

    [ "$(cat output)" = "goodbye cruel world" ] \
    || fail "DOCKER_OPTS has no effect"
}

test_that_with_different_uid_we_still_have_permissions_to_files() {
    [ -n "$TRAVIS" ] || skip "Test will only run on Travis because it involves changing system state"

    sudo adduser --gecos "" test-user </dev/null &&
    sudo chmod 777 ~test-user &&
    sudo cp $srcdir/stbt-docker /usr/bin/stbt-docker &&
    sudo chmod a+rx /usr/bin/stbt-docker &&
    sudo adduser test-user docker &&
    load_test_pack setup-script ~test-user &&
    sudo chown -R test-user:test-user . &&
    sudo chmod 700 ~test-user || fail "Test setup failed"

    sudo -u test-user bash <<-'EOF'
		stbt-docker bash -c 'touch hello' &&
		[ "$(ls -l hello | awk '{ print $3 }')" == 'test-user' ] &&
		stbt-docker sh -c 'touch $XDG_RUNTIME_DIR/test'
		EOF
    [ "$?" == 0 ] || fail "UID switching broken"
}

test_that_stbt_docker_can_import_stbt() {
    load_test_pack empty-test-pack
    "$srcdir"/stbt-docker python <<-'EOF'
	import stbt
	print stbt.__doc__.split("\n")[0]
	assert stbt.__doc__.split("\n")[0] == \
	    "Main stb-tester python module. Intended to be used with `stbt run`."
	EOF
}

test_that_user_provided_pythonpath_doesnt_prevent_us_from_importing_stbt() {
    load_test_pack with-fake-stbt
    DOCKER_OPTS="-e PYTHONPATH=/var/lib/stbt/test-pack" \
    "$srcdir"/stbt-docker python <<-'EOF'
	import stbt
	print stbt.__doc__.split("\n")[0]
	assert stbt.__doc__.split("\n")[0] == \
	    "Main stb-tester python module. Intended to be used with `stbt run`."
	EOF
}

test_that_stbt_docker_respects_pythonpath() {
    load_test_pack with-fake-stbt
    DOCKER_OPTS="-e PYTHONPATH=/var/lib/stbt/test-pack/lib" \
    "$srcdir"/stbt-docker python <<-'EOF'
	import stbt
	assert stbt.__doc__.split("\n")[0] == \
	    "Fake stbt to test stbt-docker's PYTHONPATH handling."
	EOF
}

test_that_stbt_config_file_is_absolute_path() {
    load_test_pack empty-test-pack
    "$srcdir"/stbt-docker bash -c \
        'cd config && stbt config test_pack.stbt_version | tee ../output'
    [ "$(cat output)" = "29" ] || fail "Didn't find \$STBT_CONFIG_FILE"
}

test_stbt_match() {
    load_test_pack with-tests
    "$srcdir"/stbt-docker stbt match \
        tests/videotestsrc-full-frame.png \
        tests/videotestsrc-redblue.png
}

test_stbt_lint() {
    load_test_pack with-tests
    "$srcdir"/stbt-docker stbt lint --errors-only tests/tests.py
}
