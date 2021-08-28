#!/usr/bin/env bash
source ${BASH_SOURCE%/*}/common.sh

exec_check lean --plugin ${PAPYRUS_PLUGIN} -j 0 "$f"
