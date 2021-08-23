import Papyrus.FFI
import Papyrus.IR.TypeRefs

namespace Papyrus

/--
  An opaque type representing an external
  [GenericValue](https://llvm.org/doxygen/structllvm_1_1GenericValue.html).
-/
constant Llvm.GenericValue : Type := Unit

/--
  A reference to an external LLVM
  [GenericValue](https://llvm.org/doxygen/structllvm_1_1GenericValue.html).
-/
def GenericValueRef := OwnedPtr Llvm.GenericValue

namespace  GenericValueRef

/--
  Create a integer generic of the given width with the given `Int` value.
  The value will be truncated and/or extended as necessary to make it fit.
-/
@[extern "papyrus_generic_value_of_int"]
constant ofInt (numBits : UInt32) (value : @& Int) : IO GenericValueRef

/-- Get the value of this generic as an `Int` by treating its integer bits as signed. -/
@[extern "papyrus_generic_value_to_int"]
constant toInt (self : @& GenericValueRef) : IO Int

/--
  Create a integer generic  of the given width with the given `Nat` value.
  The value will be truncated and/or extended as necessary to make it fit.
-/
@[extern "papyrus_generic_value_of_nat"]
constant ofNat (numBits : UInt32) (value : @& Nat)  : IO GenericValueRef

/-- Get the integer value of this generic as a `Nat` by treating its integer bits as unsigned. -/
@[extern "papyrus_generic_value_to_nat"]
constant toNat (self : @& GenericValueRef) : IO Nat

/-- Create a `double` generic from a `Float`. -/
@[extern "papyrus_generic_value_of_float"]
constant ofFloat (value : @& Float) : IO GenericValueRef

/-- Get the `double` value of this generic as a `Float`. -/
@[extern "papyrus_generic_value_to_float"]
constant toFloat (self : @& GenericValueRef) : IO Float

/-- Create an aggregate generic from an `Array`. -/
@[extern "papyrus_generic_value_of_array"]
constant ofArray (value : @& Array GenericValueRef) : IO GenericValueRef

/-- Get the aggregate value of this generic as an `Array`. -/
@[extern "papyrus_generic_value_to_array"]
constant toArray (self : @& GenericValueRef) : IO (Array GenericValueRef)

end GenericValueRef

namespace IntegerTypeRef

/-- Get a reference to a generic of this type with the value of `Int`. -/
def getGenericValueOfInt (value : @& Int) (self : @& IntegerTypeRef) : IO GenericValueRef := do
  GenericValueRef.ofInt (← self.getBitWidth) value

/-- Get a reference to a generic of this type with the value of `Nat`. -/
constant getGenericValueOfNat (value : @& Nat) (self : @& IntegerTypeRef) : IO GenericValueRef := do
  GenericValueRef.ofNat (← self.getBitWidth) value

end IntegerTypeRef
