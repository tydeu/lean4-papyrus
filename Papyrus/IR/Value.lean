import Papyrus.Context
import Papyrus.IR.TypeRef

namespace Papyrus

/--
  An external reference to the LLVM representation of a Value.
  See https://llvm.org/doxygen/classllvm_1_1Value.html.
-/
constant ValueRef : Type := Unit

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

/-- Print the IR of this value to standard error for debugging. -/
@[extern "papyrus_value_dump"]
constant dump (self : @& ValueRef) : IO PUnit

end ValueRef

/--
  An external reference to the LLVM representation of a User.
  See https://llvm.org/doxygen/classllvm_1_1User.html.
-/
def UserRef := ValueRef
