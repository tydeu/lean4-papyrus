import Papyrus.Context
import Papyrus.IR.Globals
import Papyrus.IR.AddressSpace
import Papyrus.IR.Types.Function

namespace Papyrus

/--
  An external reference to the LLVM representation of a
  [Function](https://llvm.org/doxygen/classllvm_1_1Function.html).
-/
def FunctionRef := GlobalObjectRef

namespace FunctionRef

/--
  Create a new unlinked function with the given type, the optional given name,
    and the given linkage in the given raw address space.
-/
@[extern "papyrus_create_function"]
constant createRaw (type : @& FunctionTypeRef) (name : @& String)
  (linkage : @& Linkage) (addrSpace : UInt32) : IO FunctionRef

/--
  Create a new unlinked function with the given type, the optional given name,
    and the given linkage in the given address space.
-/
def create (type : @& FunctionTypeRef) (name : @& String := "")
  (linkage := Linkage.external) (addrSpace := AddressSpace.default) :=
  createRaw type name linkage addrSpace.toUInt32

end FunctionRef
