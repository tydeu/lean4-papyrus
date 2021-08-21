import Papyrus.Context
import Papyrus.IR.TypeRef

namespace Papyrus

/--
  An opaque type representing an external LLVM
  [Value](https://llvm.org/doxygen/classllvm_1_1Value.html).
-/
constant Llvm.Value : Type := Unit

/--
  A reference to an external LLVM
  [Value](https://llvm.org/doxygen/classllvm_1_1Value.html).
-/
def ValueRef := LinkedLoosePtr ContextRef Llvm.Value

namespace ValueRef

/-- Get a reference to this value's type. -/
@[extern "papyrus_value_get_type"]
constant getType (self : @& ValueRef) : IO TypeRef

/-- Get whether this value has a name. -/
@[extern "papyrus_value_has_name"]
constant hasName (self : @& ValueRef) : IO Bool

/-- Get the name of this value (or the empty string if none). -/
@[extern "papyrus_value_get_name"]
constant getName (self : @& ValueRef) : IO String

/--
  Set the name of this value.
  Passing the empty string will remove the value's name.
-/
@[extern "papyrus_value_set_name"]
constant setName (name : @& String) (self : @& ValueRef) : IO PUnit

/--
  Print this value (without a newline)
  to LLVM's standard output (which may not correspond to Lean's).
-/
@[extern "papyrus_value_print"]
constant print (self : @& ValueRef) (isForDebug := false) : IO PUnit

/--
  Print this value (without a newline)
  to LLVM's standard error (which may not correspond to Lean's).
-/
@[extern "papyrus_value_eprint"]
constant eprint (self : @& ValueRef) (isForDebug := false) : IO PUnit

/-- Print this value to a string (without a newline). -/
@[extern "papyrus_value_sprint"]
constant sprint (self : @& ValueRef) (isForDebug := false) : IO String

/-- Print this value to Lean's standard output for debugging (with a newline). -/
def dump (self : @& ValueRef) : IO PUnit := do
  IO.println (← self.sprint (isForDebug := true))

end ValueRef

/--
  A reference to an external LLVM User.
  See https://llvm.org/doxygen/classllvm_1_1User.html.
-/
def UserRef := ValueRef
