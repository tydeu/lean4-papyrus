# Make C lib

echo "building c lib"
make -C c

# Make Papyrus

LLVM_CONFIG=llvm-config
LLVM_COMPONENTS="core"
PAPYRUS_C_LIB="c/build/papyrus.o"

LLVM_LIBDIR=$($LLVM_CONFIG --libdir)
LLVM_LINK_FLAGS=$($LLVM_CONFIG --ldflags)
LLVM_LIBS=$($LLVM_CONFIG --link-static --libs $LLVM_COMPONENTS)
LLVM_SYS_LIBS=$($LLVM_CONFIG --link-static --system-libs)

rm -rf build/bin
leanpkg build bin LINK_OPTS="\"$PAPYRUS_C_LIB $LLVM_LINK_FLAGS $LLVM_LIBS $LLVM_SYS_LIBS\""
