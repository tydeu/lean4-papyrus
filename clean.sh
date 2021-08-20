rm -rf build
make -C c clean
rm -rf test/lib/build
make -C plugin clean
make -C test clean
