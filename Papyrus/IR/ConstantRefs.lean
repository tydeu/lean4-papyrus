import Papyrus.Context
import Papyrus.IR.TypeRefs
import Papyrus.IR.ConstantRef

namespace Papyrus

namespace TypeRef

/- Get a reference to a null (`0`) constant of this type. -/
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

/--  Get an i1 constant for a `Bool` (i.e., `1` for `true`, `0` for `false`). -/
@[extern "papyrus_get_constant_bool"]
constant ofBool (value : Bool) : LLVM ConstantWordRef

/--  Get an i8 constant for a `UInt8`. -/
@[extern "papyrus_get_constant_uint8"]
constant ofUInt8 (value : UInt8) : LLVM ConstantWordRef

/--  Get an i16 constant for a `UInt16`. -/
@[extern "papyrus_get_constant_uint16"]
constant ofUInt16 (value : UInt16) : LLVM ConstantWordRef

/--  Get an i32 constant for a `UInt32`. -/
@[extern "papyrus_get_constant_uint32"]
constant ofUInt32 (value : UInt32) : LLVM ConstantWordRef

/--  Get an i64 constant for a `UInt64`. -/
@[extern "papyrus_get_constant_uint64"]
constant ofUInt64 (value : UInt64) : LLVM ConstantWordRef

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


--------------------------------------------------------------------------------
-- Constant Arrays
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [ConstantDataSequential](https://llvm.org/doxygen/classllvm_1_1ConstantDataSequential.html).
-/
def ConstantDataSequentialRef := ConstantDataRef

/--
  A reference to an external LLVM
  [ConstantDataArray](https://llvm.org/doxygen/classllvm_1_1ConstantDataArray.html).
-/
def ConstantDataArrayRef := ConstantDataSequentialRef

namespace ConstantDataArrayRef

/-- Get the array type of this constant.  -/
def getType (self : @& ConstantDataArrayRef) : IO ArrayTypeRef :=
  ValueRef.getType self

/-- Get the type of elements of this constant.  -/
def getElementType (self : @& ConstantDataArrayRef) : IO TypeRef := do
  (← self.getType).getElementType

/--
  Get reference to a UTF-8 encoded string constant.
  If `withNull` is true, the string is null terminated.
-/
@[extern "papyrus_get_constant_string"]
constant getString (str : @& String) (withNull := true) : LLVM ConstantDataArrayRef
