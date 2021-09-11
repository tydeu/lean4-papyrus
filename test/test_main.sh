#!/usr/bin/env bash
source ${BASH_SOURCE%/*}/common.sh

exec_check lean ${LEAN_OPTS} --run -j 0 "$f"
