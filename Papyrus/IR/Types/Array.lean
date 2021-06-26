import Papyrus.IR.Types.TypeRef

namespace Papyrus

-- # Array Type Reference

/--
  A reference to the LLVM representation of a
  [ArrayType](https://llvm.org/doxygen/classllvm_1_1ArrayType.html).
-/
def ArrayTypeRef := TypeRef

namespace ArrayTypeRef

/--
  Get a reference to the LLVM array type of
    the given element type with the given number of elements.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_array_type"]
constant get (elemType : @& TypeRef) (numElems : UInt64) : IO ArrayTypeRef

/-- Get a reference to the element type of this array type. -/
@[extern "papyrus_array_type_get_element_type"]
constant getElementType (self : @& ArrayTypeRef) : IO TypeRef

/-- Get the raw number of elements in this array type. -/
@[extern "papyrus_array_type_get_num_elements"]
constant getRawSize (self : @& ArrayTypeRef) : IO UInt64

/-- Get the number of elements in this array type (as a `Nat`).. -/
@[extern "papyrus_array_type_get_num_elements"]
constant getSize (self : @& ArrayTypeRef) : IO Nat

end ArrayTypeRef

-- # Pure Array Type

/-- A fixed-length homogenous array type. -/
structure ArrayType (α) (numElems : Nat) where
  elementType : α

/-- An array type of the given type with the given size. -/
def arrayType (elementType : α) (numElems : Nat) : ArrayType α numElems  :=
  ArrayType.mk elementType

namespace ArrayType
variable {numElems : Nat}

/-- The number of elements in this type. -/
def size (self : ArrayType α numElems) := numElems

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element type
  and size are valid.
-/
def getRef [ToTypeRef α] (self : ArrayType α numElems) : LLVM ArrayTypeRef := do
  ArrayTypeRef.get (← toTypeRef self.elementType) numElems.toUInt64

end ArrayType

instance [ToTypeRef α] {numElems} : ToTypeRef (ArrayType α numElems) :=
  ⟨ArrayType.getRef⟩
