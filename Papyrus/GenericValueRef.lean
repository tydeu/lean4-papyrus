import Papyrus.IR.TypeRefs

namespace Papyrus

/--
  A reference to the LLVM representation of a
  [GenericValue](https://llvm.org/doxygen/structllvm_1_1GenericValue.html).
-/
constant GenericValueRef : Type := Unit

namespace  GenericValueRef

/-- Get the value of this generic as an `Int` by treating its integer bits as signed. -/
@[extern "papyrus_generic_value_to_int"]
constant toInt (self : @& GenericValueRef) : IO Int

/-- Get the value of this generic as an `Nat` by treating its integer bits as unsigned. -/
@[extern "papyrus_generic_value_to_nat"]
constant toNat (self : @& GenericValueRef) : IO Nat

end GenericValueRef

namespace IntegerTypeRef

/-- Get a reference to a generic of this type with the value of `Int`. -/
@[extern "papyrus_generic_value_of_int"]
constant getGenericValueOfInt (value : @& Int) (self : @& IntegerTypeRef) : IO GenericValueRef

/-- Get a reference to a generic of this type with the value of `Nat`. -/
@[extern "papyrus_generic_value_of_nat"]
constant getGenericValueOfNat (value : @& Nat) (self : @& IntegerTypeRef) : IO GenericValueRef

end IntegerTypeRef
