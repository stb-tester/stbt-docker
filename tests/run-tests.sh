#!/bin/bash

# Automated tests to test the stb-tester framework itself.

#/ Usage: run-tests.sh [options] [testsuite or testcase names...]
#/
#/         -l      Leave the scratch dir created in /tmp.
#/         -v      Verbose (don't suppress console output from tests).
#/
#/         If any test names are specified, only those test cases will be run.


while getopts "lvi" option; do
    case $option in
        l) leave_scratch_dir=true;;
        v) verbose=true;;
        *) grep '^#/' < "$0" | cut -c4- >&2; exit 1;; # Print usage message
    esac
done
shift $(($OPTIND-1))

export testdir="$(cd "$(dirname "$0")" && pwd)"
export srcdir="$testdir/.."
export PYTHONUNBUFFERED=x

testsuites=()
testcases=()
while [[ $# -gt 0 ]]; do
    [[ -f $1 ]] && testsuites+=($1) || testcases+=($1)
    shift
done
for testsuite in ${testsuites[*]:-"$(dirname "$0")"/test-*.sh}; do
    source $testsuite
done
: ${testcases:=$(declare -F | awk '/ test_/ {print $3}')}

cd "$testdir"

fail() { echo "error: $*"; exit 1; }
skip() { echo "skipping: $*"; exit 77; }

run() {
    scratchdir=$(mktemp -d -p "$testdir" -t stb-tester.XXX)
    [ -n "$scratchdir" ] || { echo "$0: mktemp failed" >&2; exit 1; }
    printf "$(bold $1...) "
    ( cd "$scratchdir" && $1 ) > "$scratchdir/log" 2>&1
    local status=$?
    case $status in
        0) echo "$(green OK)";;
        77) status=0; echo "$(yellow SKIPPED)"; cat "$scratchdir/log";;
        *) echo "$(red FAIL)";;
    esac
    if [[ "$verbose" = "true" || $status -ne 0 ]]; then
        echo "Showing '$scratchdir/log':"
        cat "$scratchdir/log"
        echo ""
    fi
    if [[ "$leave_scratch_dir" != "true" && $status -eq 0 ]]; then
        rm -rf "$scratchdir"
    fi
    [ $status -eq 0 ]
}

bold() { tput bold; printf "%s" "$*"; tput sgr0; }
green() { tput setaf 2; printf "%s" "$*"; tput sgr0; }
red() { tput setaf 1; printf "%s" "$*"; tput sgr0; }
yellow() { tput setaf 3; printf "%s" "$*"; tput sgr0; }

# Run the tests ############################################################
ret=0
for t in ${testcases[*]}; do
    run $t || ret=1
done
exit $ret


# bash-completion script: Add the below to ~/.bash_completion
_stbt_run_tests() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local testdir="$(dirname \
        $(echo $COMP_LINE | grep -o '\b[^ ]*run-tests\.sh\b'))"
    local testfiles="$(\ls $testdir/test-*.sh | sed -e 's,^\./,,')"
    local testcases="$(awk -F'[ ()]' '/^test_[a-z_]*\(\)/ {print $1}' $testfiles)"
    COMPREPLY=( $(
        compgen -W "$testcases $testfiles" -- "$cur") )
}
complete -F _stbt_run_tests run-tests.sh
