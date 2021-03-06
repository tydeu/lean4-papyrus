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
structure ConstantDataRef extends ConstantRef
instance : Coe ConstantDataRef ConstantRef := ⟨(·.toConstantRef)⟩

--------------------------------------------------------------------------------
-- Constant Ints (Words / Integers / Natural)
--------------------------------------------------------------------------------

-- # Constant Word

/--
  A reference to an external LLVM
  [ConstantInt](https://llvm.org/doxygen/classllvm_1_1ConstantInt.html).

  Such a constant can be used to represent a block of bits (i.e., a word),
  an unsigned integer (a natural), or a true integer.
-/
structure ConstantIntRef extends ConstantDataRef where
  is_constant_int : toValueRef.valueKind = ValueKind.constantInt

instance : Coe ConstantIntRef ConstantDataRef := ⟨(·.toConstantDataRef)⟩

namespace ConstantIntRef

/-- Cast a general `ValueRef` to a `ConstantIntRef` given proof it is one. -/
def cast (val : ValueRef) (h : val.valueKind = ValueKind.constantInt) : ConstantIntRef :=
  {toValueRef := val, is_constant_int := h}

/--  Get the LLVM true constant (i.e., `i1 0`). -/
@[extern "papyrus_get_constant_false"]
constant getFalse : LlvmM ConstantIntRef

/--  Get the LLVM true constant (i.e., `i1 1`). -/
@[extern "papyrus_get_constant_true"]
constant getTrue : LlvmM ConstantIntRef

/--  Get an i1 constant for a `Bool` (i.e., `1` for `true`, `0` for `false`). -/
def ofBool : (value : Bool) → LlvmM ConstantIntRef
| false => getFalse
| true => getTrue

/--  Get an i8 constant for a `UInt8`. -/
@[extern "papyrus_get_constant_uint8"]
constant ofUInt8 (value : UInt8) : LlvmM ConstantIntRef

/--  Get an i16 constant for a `UInt16`. -/
@[extern "papyrus_get_constant_uint16"]
constant ofUInt16 (value : UInt16) : LlvmM ConstantIntRef

/--  Get an i32 constant for a `UInt32`. -/
@[extern "papyrus_get_constant_uint32"]
constant ofUInt32 (value : UInt32) : LlvmM ConstantIntRef

/--  Get an i64 constant for a `UInt64`. -/
@[extern "papyrus_get_constant_uint64"]
constant ofUInt64 (value : UInt64) : LlvmM ConstantIntRef

/--  Get a constant with the given Nat value truncated to `numBits`. -/
@[extern "papyrus_get_constant_nat_of_size"]
constant ofNat (numBits : UInt32) (value : @& Nat) : LlvmM ConstantIntRef

/--  Get a constant with the given Int value truncated to `numBits`. -/
@[extern "papyrus_get_constant_int_of_size"]
constant ofInt (numBits : UInt32) (value : @& Int) : LlvmM ConstantIntRef

/-- Get the integer type of this constant.  -/
@[extern "papyrus_value_get_type"]
constant getType (self : @& ConstantIntRef) : IO IntegerTypeRef

/--
  Get the value of this constant as a `Nat`.
  That is, treat its bits as representing a native unsigned integer.
-/
@[extern "papyrus_constant_int_get_nat_value"]
constant getNatValue (self : @& ConstantIntRef) : IO Nat

/--
  Get the value of this constant as an `Int`.
  That is, treat its bits as representing a native integer.
-/
@[extern "papyrus_constant_int_get_int_value"]
constant getIntValue (self : @& ConstantIntRef) : IO Int

end ConstantIntRef

-- # Integer Type -> ConstantInt/ConstantNat Convenience Functions

namespace IntegerTypeRef

/--
  Get a reference to a constant of this type with the given `Int` value.
  The value will be truncated and/or extended as necessary to make it fit.
-/
@[extern "papyrus_get_constant_int_of_type"]
constant getConstantInt (value : @& Int) (self : @& IntegerTypeRef) : IO ConstantIntRef

/--
  Get a reference to a constant of this type with the given `Nat` value.
  The value will be truncated and/or extended as necessary to make it fit.
-/
@[extern "papyrus_get_constant_nat_of_type"]
constant getConstantNat (value : @& Nat) (self : @& IntegerTypeRef) : IO ConstantIntRef

end IntegerTypeRef

--------------------------------------------------------------------------------
-- Constant Data Arrays
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [ConstantDataSequential](https://llvm.org/doxygen/classllvm_1_1ConstantDataSequential.html).
-/
structure ConstantDataSequentialRef extends ConstantDataRef
instance : Coe ConstantDataSequentialRef ConstantDataRef := ⟨(·.toConstantDataRef)⟩

namespace ConstantDataSequentialRef

/-- Check whether this constant is an i8 array. -/
@[extern "papyrus_constant_data_sequential_is_string"]
constant isString (const : @& ConstantDataSequentialRef) : IO Bool

/-- Get the value of this constant as a `String` by treating its bytes as characters. -/
@[extern "papyrus_constant_data_sequential_get_as_string"]
constant getAsString (const : @& ConstantDataSequentialRef) : IO String

end ConstantDataSequentialRef

/--
  A reference to an external LLVM
  [ConstantDataArray](https://llvm.org/doxygen/classllvm_1_1ConstantDataArray.html).
-/
structure ConstantDataArrayRef extends ConstantDataSequentialRef where
  is_constant_data_array : toValueRef.valueKind = ValueKind.constantDataArray

instance : Coe ConstantDataArrayRef ConstantDataSequentialRef :=
  ⟨(·.toConstantDataSequentialRef)⟩

namespace ConstantDataArrayRef

/-- Cast a general `ValueRef` to a `ConstantDataArrayRef` given proof it is one. -/
def cast (val : ValueRef) (h : val.valueKind = ValueKind.constantDataArray) : ConstantDataArrayRef :=
  {toValueRef := val, is_constant_data_array := h}

/-- Get the array type of this constant.  -/
@[extern "papyrus_value_get_type"]
constant getType (self : @& ConstantDataArrayRef) : IO ArrayTypeRef

/-- Get the type of elements of this constant.  -/
def getElementType (self : @& ConstantDataArrayRef) : IO TypeRef := do
  (← self.getType).getElementType

/--
  Get reference to a UTF-8 encoded string constant.
  If `withNull` is true, the string is null terminated.
-/
@[extern "papyrus_get_constant_string"]
constant ofString (str : @& String) (withNull := true) : LlvmM ConstantDataArrayRef

end ConstantDataArrayRef

--------------------------------------------------------------------------------
-- Constant Expressions
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [ConstantExpr](https://llvm.org/doxygen/classllvm_1_1ConstantExpr.html).
-/
structure ConstantExprRef extends ConstantRef where
  is_constant_expr : toValueRef.valueKind = ValueKind.constantExpr

instance : Coe ConstantExprRef ConstantRef := ⟨(·.toConstantRef)⟩

namespace ConstantExprRef

/-- Cast a general `ValueRef` to a `ConstantExprRef` given proof it is one. -/
def cast (val : ValueRef) (h : val.valueKind = ValueKind.constantExpr) : ConstantExprRef :=
  {toValueRef := val, is_constant_expr := h}

-- ## `getelementptr`

/--
  Get a constant GEP expression that
  calculates the address of the given sub-element of an aggregate data structure.

  See the [`getelementptr`](https://llvm.org/docs/LangRef.html#getelementptr-instruction)
  docs for more details.
-/
@[extern "papyrus_constant_expr_get_element_ptr"]
constant getGetElementPtr (aggregate : @& ConstantRef)
  (indices : @& Array ConstantRef) (inBounds := false)
  : IO ConstantRef

/--
  Get a constant GEP expression with an additional `inrange` index.

  See the [`getelementptr`](https://llvm.org/docs/LangRef.html#getelementptr-instruction)
  docs for more details.
-/
@[extern "papyrus_constant_expr_get_element_ptr_in_range"]
constant getGetElementPtrInRange (aggregate : @& ConstantRef)
  (indices : @& Array ConstantRef) (inRange : UInt32) (inBounds := false)
  : IO ConstantRef

-- ## `ptrtoint`

/--
  Get a reference to a constant `ptrtoint` expression that
  converts the given constant integer to the given pointer type.
-/
@[extern "papyrus_constant_expr_get_ptr_to_int"]
constant getPtrToInt (const : @& ConstantRef) (type : @& TypeRef) : IO ConstantRef

-- ## `inttoptr`

/--
  Get a reference to a constant `inttoptr` expression that
  converts the given constant pointer to the given integer type.
-/
@[extern "papyrus_constant_expr_get_int_to_ptr"]
constant getIntToPtr (const : @& ConstantRef) (type : @& TypeRef) : IO ConstantRef

end ConstantExprRef
