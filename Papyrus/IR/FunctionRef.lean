import Papyrus.Context
import Papyrus.IR.AddressSpace
import Papyrus.IR.BasicBlockRef
import Papyrus.IR.GlobalRefs
import Papyrus.IR.TypeRefs

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

/-- Get the array of references to the basic blocks of this function. -/
@[extern "papyrus_function_get_basic_blocks"]
constant getBasicBlocks (self : @& FunctionRef) : IO (Array BasicBlockRef)

/-- Add a basic block to the end of this function. -/
@[extern "papyrus_function_append_basic_block"]
constant appendBasicBlock (bb : @& BasicBlockRef) (self : @& FunctionRef) : IO PUnit

/-- Check the function for errors (returns *true* if any errors are found). -/
@[extern "papyrus_function_verify"]
constant verify (self : @& FunctionRef) : IO Bool

end FunctionRef
