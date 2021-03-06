cd ${BASH_SOURCE%/*}

OS_NAME=${OS}
if [[ "${OS_NAME}" != "Windows_NT" ]]; then
  OS_NAME=$(uname -s)
fi

export LEAN_PATH=../build/${OS_NAME}
PLUGIN=../plugin/build/PapyrusPlugin
if [[ "${OS_NAME}" == "Windows_NT" ]]; then
    export LEAN_OPTS="--plugin ${PLUGIN}"
else
    LEAN_LIBDIR=$(lean --print-libdir)
    export LD_PRELOAD="${LEAN_LIBDIR}/libleanshared.so:${PLUGIN}.so"
    export LEAN_OPTS="--plugin ${PLUGIN}.so"
fi

# The shells scripts in this directory were adapted from the Lean 4 sources

set -euo pipefail

ulimit -s 8192
DIFF=diff
if diff --color --help >/dev/null 2>&1; then
    DIFF="diff --color";
fi

function fail {
    echo $1
    exit 1
}

[ $# -eq 0 ] && fail "Usage: ${0##*/} [-i] test-file.lean"

INTERACTIVE=no
if [ $1 == "-i" ]; then
    INTERACTIVE=yes
    shift
fi

[ $# -eq 1 ] || fail "Usage: ${0##*/} [-i] test-file.lean"
f=${1##${BASH_SOURCE%/*}/} # test-file path realtive to the test directory
shift

function compile_lean {
    lean --c="$f.c" "$f" || fail "Failed to compile $f into C file"
    leanc -O3 -DNDEBUG -o "$f.out" "$@" "$f.c" || fail "Failed to compile C file $f.c"
}

function exec_capture {
    # mvar suffixes like in `?m.123` are deterministic but prone to change on minor changes, so strip them
    "$@" 2>&1 | sed -E 's/(\?\w)\.[0-9]+/\1/g' > "$f.produced.out"
}

# Remark: `${var+x}` is a parameter expansion which evaluates to nothing if `var` is unset, and substitutes the string `x` otherwise.
function exec_check {
    ret=0
    [ -n "${expected_ret+x}" ] || expected_ret=0
    [ -f "$f.expected.ret" ] && expected_ret=$(< "$f.expected.ret")
    exec_capture "$@" || ret=$?
    if [ -n "$expected_ret" ] && [ $ret -ne $expected_ret ]; then
        echo "Unexpected return code $ret executing '$@'; expected $expected_ret. Output:"
        cat "$f.produced.out"
        exit 1
    fi
}

function diff_produced {
    if test -f "$f.expected.out"; then
        if $DIFF -au --strip-trailing-cr -I "executing external script" "$f.expected.out" "$f.produced.out"; then
            exit 0
        else
            echo "ERROR: file $f.produced.out does not match $f.expected.out"
            if [ $INTERACTIVE == "yes" ]; then
                if ! type "meld" &> /dev/null; then
                    read -p "copy $f.produced.out (y/n)? "
                    if [ $REPLY == "y" ]; then
                        cp -- "$f.produced.out" "$f.expected.out"
                        echo "-- copied $f.produced.out --> $f.expected.out"
                    fi
                else
                    meld "$f.produced.out" "$f.expected.out"
                    if diff -I "executing external script" "$f.expected.out" "$f.produced.out"; then
                        echo "-- mismatch was fixed"
                    fi
                fi
            fi
            exit 1
        fi
    else
        echo "ERROR: file $f.expected.out does not exist"
        if [ $INTERACTIVE == "yes" ]; then
            read -p "copy $f.produced.out (y/n)? "
            if [ $REPLY == "y" ]; then
                cp -- "$f.produced.out" "$f.expected.out"
                echo "-- copied $f.produced.out --> $f.expected.out"
            fi
        fi
        exit 1
    fi
}
