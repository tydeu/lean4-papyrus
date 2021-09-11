#!/usr/bin/env bash

MY_DIR=$(dirname $0)
PLUGIN=${MY_DIR}/plugin/build/PapyrusPlugin

OS_NAME=${OS}
if [[ "${OS_NAME}" != "Windows_NT" ]]; then
  OS_NAME=$(uname -s)
fi

export LEAN_PATH="${MY_DIR}/build/${OS_NAME}"
if [[ "$OS_NAME" == "Windows_NT" ]]; then
  lean --plugin ${PLUGIN} "$@"
else
  LEAN_LIBDIR=$(lean --print-libdir)
  export LD_PRELOAD="${LEAN_LIBDIR}/libleanshared.so:${PLUGIN}.so"
  lean --plugin ${PLUGIN}.so "$@"
fi
