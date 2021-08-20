MY_DIR=`dirname $0`
LEAN_PATH=${MY_DIR}/build lean --plugin ${MY_DIR}/plugin/build/PapyrusPlugin "$@"
