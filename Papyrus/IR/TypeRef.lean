import Papyrus.FFI
import Papyrus.Context
import Papyrus.IR.TypeID

namespace Papyrus

/--
  An opaque type representing and external LLVM
  [Type](https://llvm.org/doxygen/classllvm_1_1Type.html).
-/
constant Llvm.Type : Type := Unit

/--
  A reference to an external LLVM
  [Type](https://llvm.org/doxygen/classllvm_1_1Type.html).
-/
structure TypeRef where
  ptr : LinkedLoosePtr ContextRef Llvm.Type

namespace TypeRef

/-- The `TypeID` of this type. -/
@[extern "papyrus_type_id"]
constant typeID (self : TypeRef) : TypeID

/-- Get the owning LLVM context of this type. -/
@[extern "papyrus_type_get_context"]
constant getContext (self : TypeRef) : IO ContextRef

/--
  Print this type (without a newline) to
  LLVM's standard output (which may not correspond to Lean's).

  If `noDetails`, print just the name of identified struct types.
-/
@[extern "papyrus_type_print"]
constant print (self : @& TypeRef) (isForDebug := false) (noDetails := false) : IO PUnit

/--
  Print this type (without a newline)
  to LLVM's standard error (which may not correspond to Lean's).

  If `noDetails`, print just the name of identified struct types.
-/
@[extern "papyrus_type_eprint"]
constant eprint (self : @& TypeRef) (isForDebug := false) (noDetails := false) : IO PUnit

/--
  Print this type to a string (without a newline).

  If `noDetails`, print just the name of identified struct types.
-/
@[extern "papyrus_type_sprint"]
constant sprint (self : @& TypeRef) (isForDebug := false) (noDetails := false) : IO String

/-- Print this type to Lean's standard output for debugging (with a newline). -/
def dump (self : @& TypeRef) : IO PUnit := do
  IO.println (← self.sprint (isForDebug := true))
