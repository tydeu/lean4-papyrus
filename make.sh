# Make C lib

echo "building c lib"
make -C c "$@"

# Make Papyrus

leanpkg build lib "$@"

# Make Test Lib

cd test/lib
leanpkg build lib "$@"
cd ../..

# Make Tests

echo "testing papyrus"
make -C test "$@"
