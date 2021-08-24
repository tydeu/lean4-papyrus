#!/usr/bin/env bash
source ./common.sh

exec_check lean --plugin ${PAPYRUS_PLUGIN} --run -j 0 "$f"
