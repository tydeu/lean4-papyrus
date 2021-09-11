#!/usr/bin/env bash
source ${BASH_SOURCE%/*}/common.sh

# these tests don't have to succeed
exec_capture lean ${LEAN_OPTS} -DprintMessageEndPos=true "$f" || true
diff_produced
