MY_DIR=`dirname $0`
lean --plugin ${MY_DIR}/plugin/build/PapyrusPlugin "$@"
