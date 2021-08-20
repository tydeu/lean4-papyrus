# Make C lib

echo "building c lib"
make -C c "$@"

# Make Papyrus

leanpkg build lib "$@"

# Make Plugin

echo "building plugin"
make -C plugin "$@"

# Make Test Lib

cd test/lib
leanpkg build lib "$@"
cd ../..

# Make Tests

echo "testing papyrus"
make -C test "$@"
