# Make C lib

echo "building c"
make -C c

# Make Papyrus

LLVM_CONFIG=llvm-config
LLVM_COMPONENTS="core bitreader"
LEAN_LLVM_LIB="c/build/lean_llvm.o"

LLVM_LIBDIR=$($LLVM_CONFIG --libdir)
LLVM_LINK_FLAGS=$($LLVM_CONFIG --ldflags)
LLVM_LIBS=$($LLVM_CONFIG --link-static --libs $LLVM_COMPONENTS)
LLVM_SYS_LIBS=$($LLVM_CONFIG --link-static --system-libs)

leanpkg build bin LINK_OPTS="\"$LEAN_LLVM_LIB $LLVM_LINK_FLAGS $LLVM_LIBS $LLVM_SYS_LIBS\""
