#!/usr/bin/env bash
source ./common.sh

PLUGIN=../../plugin/build/PapyrusPlugin

# these tests don't have to succeed
exec_capture lean --plugin ${PLUGIN} -DprintMessageEndPos=true "$f" || true
diff_produced
