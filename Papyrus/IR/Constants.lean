import Papyrus.Context
import Papyrus.IR.Value

namespace Papyrus

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
