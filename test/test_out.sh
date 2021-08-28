#!/usr/bin/env bash
source ${BASH_SOURCE%/*}/common.sh

# these tests don't have to succeed
exec_capture lean --plugin ${PAPYRUS_PLUGIN} -DprintMessageEndPos=true "$f" || true
diff_produced
