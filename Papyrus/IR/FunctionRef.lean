import Papyrus.Context
import Papyrus.IR.AddressSpace
import Papyrus.IR.CallingConvention
import Papyrus.IR.BasicBlockRef
import Papyrus.IR.GlobalRefs
import Papyrus.IR.ArgumentRef
import Papyrus.IR.TypeRefs

namespace Papyrus

/--
  A reference to an external LLVM
  [Function](https://llvm.org/doxygen/classllvm_1_1Function.html).
-/
structure FunctionRef extends GlobalObjectRef where
  is_function : toValueRef.valueKind = ValueKind.function

instance : Coe FunctionRef GlobalObjectRef := ⟨(·.toGlobalObjectRef)⟩

namespace FunctionRef

/-- Cast a general `ValueRef` to a `FunctionRef` given proof it is one. -/
def cast (val : ValueRef) (h : val.valueKind = ValueKind.function) : FunctionRef :=
  {toValueRef := val, is_function := h}

/--
  Create a new unlinked function with the given type, the optional given name,
    and the given linkage in the given address space.
-/
@[extern "papyrus_function_create"]
constant create (type : @& FunctionTypeRef) (name : @& String := "")
  (linkage := Linkage.external) (addrSpace := AddressSpace.default)
  : IO FunctionRef

/-- Get the function type of this function.  -/
@[extern "papyrus_global_value_get_value_type"]
constant getValueType (self : @& FunctionRef) : IO FunctionTypeRef

/-- Get the function type of this function.  -/
abbrev getFunctionType (self : FunctionRef) := self.getValueType

/-- Get the nth argument of thee this function. -/
@[extern "papyrus_function_get_arg"]
constant getArg (argNo : @& UInt32) (self : @& FunctionRef) : IO ArgumentRef

/-- Get the array of references to the basic blocks of this function. -/
@[extern "papyrus_function_get_basic_blocks"]
constant getBasicBlocks (self : @& FunctionRef) : IO (Array BasicBlockRef)

/-- Add a basic block to the end of this function. -/
@[extern "papyrus_function_append_basic_block"]
constant appendBasicBlock (bb : @& BasicBlockRef) (self : @& FunctionRef) : IO PUnit

/-- Check this function for errors. Errors are reported inside the `IO` monad. -/
@[extern "papyrus_function_verify"]
constant verify (self : @& FunctionRef) : IO PUnit

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
