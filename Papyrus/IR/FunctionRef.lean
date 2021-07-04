import Papyrus.Context
import Papyrus.IR.AddressSpace
import Papyrus.IR.CallingConvention
import Papyrus.IR.BasicBlockRef
import Papyrus.IR.GlobalRefs
import Papyrus.IR.TypeRefs

namespace Papyrus

/--
  A reference to an external LLVM
  [Function](https://llvm.org/doxygen/classllvm_1_1Function.html).
-/
def FunctionRef := GlobalObjectRef

namespace FunctionRef

/--
  Create a new unlinked function with the given type, the optional given name,
    and the given linkage in the given address space.
-/
@[extern "papyrus_function_create"]
constant create (type : @& FunctionTypeRef) (name : @& String := "")
  (linkage := Linkage.external) (addrSpace := AddressSpace.default)
  : IO FunctionRef

/-- Get the type of this function.  -/
def getType (self : @& FunctionRef) : IO FunctionTypeRef :=
  GlobalValueRef.getType self

/-- Get the array of references to the basic blocks of this function. -/
@[extern "papyrus_function_get_basic_blocks"]
constant getBasicBlocks (self : @& FunctionRef) : IO (Array BasicBlockRef)

/-- Add a basic block to the end of this function. -/
@[extern "papyrus_function_append_basic_block"]
constant appendBasicBlock (bb : @& BasicBlockRef) (self : @& FunctionRef) : IO PUnit

/-- Check the function for errors (returns *true* if any errors are found). -/
@[extern "papyrus_function_verify"]
constant verify (self : @& FunctionRef) : IO Bool

/-- Get whether this function has a specified garbage collection algorithm. -/
@[extern "papyrus_function_has_gc"]
constant hasGC (self : @& FunctionRef) : IO Bool

/--
  Get the name of the garbage collection algorithm used in code generation.
  It is only legal to call this if a garbage collection algorithm has been
  specified (i.e., `hasGC` returns true).
-/
@[extern "papyrus_function_get_gc"]
constant getGC (self : @& FunctionRef) : IO String

/-- Set the name of the garbage collection algorithm used in code generation. -/
@[extern "papyrus_function_set_gc"]
constant setGC (gc : @& String) (self : @& FunctionRef) : IO PUnit

/-- Remove any specified garbage collection algorithm for this function. -/
@[extern "papyrus_function_clear_gc"]
constant clearGC (self : @& FunctionRef) : IO PUnit

/-- Get the calling convention of this function. -/
@[extern "papyrus_function_get_calling_convention"]
constant getCallingConvention (self : @& FunctionRef) : IO CallingConvention

/-- Set the calling convention of this function. -/
@[extern "papyrus_function_set_calling_convention"]
constant setCallingConvention (cc : CallingConvention)
  (self : @& FunctionRef) : IO PUnit

end FunctionRef
