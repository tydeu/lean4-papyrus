import Papyrus.Context
import Papyrus.IR.TypeRefs
import Papyrus.IR.ConstantRef

namespace Papyrus

namespace TypeRef

/- Get a reference to a constant of this type with all bits set to `0`. -/
@[extern "papyrus_get_null_constant"]
constant getNullConstant (self : @& TypeRef) : IO ConstantRef

/- Get a reference to a constant of this type with all bits set to `1`. -/
@[extern "papyrus_get_all_ones_constant"]
constant getAllOnesConstant (self : @& TypeRef) : IO ConstantRef

end TypeRef

/--
  A reference to an external LLVM
  [ConstantData](https://llvm.org/doxygen/classllvm_1_1ConstantData.html).
-/
def ConstantDataRef := ConstantRef

--------------------------------------------------------------------------------
-- Constant Word/Int/Nat
--------------------------------------------------------------------------------

-- # Constant Word

/--
  A reference to an external LLVM
  [ConstantInt](https://llvm.org/doxygen/classllvm_1_1ConstantInt.html)
  that is treated simply as a block of bits.
-/
def ConstantWordRef := ConstantDataRef

namespace ConstantWordRef

/-- Get the integer type of this constant.  -/
def getType (self : @& ConstantWordRef) : IO IntegerTypeRef :=
  ValueRef.getType self

/--
  Get the value of this constant as an `Int`.
  That is, treat its bits as representing a native integer.
-/
@[extern "papyrus_constant_word_get_int_value"]
constant getIntValue (self : @& ConstantWordRef) : IO Int

/--
  Get the value of this constant as a `Nat`.
  That is, treat its bits as representing a native unsigned integer.
-/
@[extern "papyrus_constant_word_get_nat_value"]
constant getNatValue (self : @& ConstantWordRef) : IO Nat

end ConstantWordRef

-- # Constant Int

/--
  A reference to an external LLVM
  [ConstantInt](https://llvm.org/doxygen/classllvm_1_1ConstantInt.html)
  that is treated as an `Int` (i.e., a signed native ).
-/
def ConstantIntRef := ConstantWordRef

/-- Get the value of this constant (as an `Int`). -/
def ConstantIntRef.getValue (self : ConstantIntRef) :=
  ConstantWordRef.getIntValue self

-- # Constant Nat

/--
  A reference to an external LLVM
  [ConstantInt](https://llvm.org/doxygen/classllvm_1_1ConstantInt.html)
  that is treated as a `Nat`.
-/
def ConstantNatRef := ConstantWordRef

/-- Get the value of this constant (as a `Nat`). -/
def ConstantNatRef.getValue (self : ConstantNatRef) :=
  ConstantWordRef.getNatValue self

-- # Integer Type -> ConstantInt/ConstantNat Convenience Functions

namespace IntegerTypeRef

/--
  Get a reference to a constant of this type with the given `Int` value.
  The value will be truncated and/or extended as necessary to make it fit.
-/
@[extern "papyrus_get_constant_int"]
constant getConstantInt (value : @& Int) (self : @& IntegerTypeRef) : IO ConstantIntRef

/--
  Get a reference to a constant of this type with the given `Nat` value.
  The value will be truncated and/or extended as necessary to make it fit.
-/
@[extern "papyrus_get_constant_nat"]
constant getConstantNat (value : @& Nat) (self : @& IntegerTypeRef) : IO ConstantNatRef

end IntegerTypeRef
