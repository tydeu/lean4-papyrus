import Papyrus.Context
import Papyrus.Types.TypeRef

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

/-- Get the name of this value (or the emptry string if none). -/
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

/--
  An external reference to the LLVM representation of a Constant.
  See https://llvm.org/doxygen/classllvm_1_1Constant.html.
-/
def ConstantRef := UserRef

namespace TypeRef

/- Get a reference to a constant of this type with all bits set to `0`. -/
@[extern "papyrus_get_null_constant"]
constant getNullConstant (self : @& TypeRef) : IO ConstantRef

/- Get a reference to a constant of this type with all bits set to `1`. -/
@[extern "papyrus_get_all_ones_constant"]
constant getAllOnesConstant (self : @& TypeRef) : IO ConstantRef

end TypeRef

/--
  An external reference to the LLVM representation of a ConstantData.
  See https://llvm.org/doxygen/classllvm_1_1ConstantData.html.
-/
def ConstantDataRef := ConstantRef

/--
  An external reference to the LLVM representation of a ConstantInt.
  See https://llvm.org/doxygen/classllvm_1_1ConstantInt.html.
-/
def ConstantIntRef := ConstantDataRef

namespace ConstantIntRef

/--
  Get a reference to a constant integer of the given value with the given type.
  The value will be truncated and/or extended as necessary to make it fit.
-/
@[extern "papyrus_get_constant_int"]
constant get (value : @& Int) (type : @& TypeRef) : LLVM ConstantIntRef

/-- Get the Int value of this constant. -/
@[extern "papyrus_constant_int_get_value"]
constant getValue (self : @& ConstantIntRef) : IO Int

/--
  Get the Nat value of this constant.
  That is, treat this constant as unsigned.
-/
@[extern "papyrus_constant_int_get_nat_value"]
constant getNatValue (self : @& ConstantIntRef) : IO Nat

end ConstantIntRef
