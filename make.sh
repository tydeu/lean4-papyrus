# Make C lib

echo "building c lib"
make -C c "$@"

# Make Papyrus

leanpkg build lib "$@"

# Make Test

echo "testing papyrus"
make -C test "$@"
