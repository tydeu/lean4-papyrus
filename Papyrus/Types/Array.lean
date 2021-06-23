import Papyrus.Types.TypeRef

namespace Papyrus

/-- A fixed-length homogenous array type. -/
structure ArrayType (α) (numElems : Nat) where
  elementType : α

/-- Make a new array type of the given type and the given size. -/
def ArrayType.mk' (elementType : α) (numElems : Nat) : ArrayType α numElems :=
  ArrayType.mk elementType

/-- An array type of the given type and the given size. -/
def arrayType (elementType : α) (numElems : Nat) :=
  ArrayType.mk' elementType numElems

@[extern "papyrus_get_array_type"]
private constant getArrayTypeRef
  (elemType : @& TypeRef) (numElems : UInt64) : IO TypeRef

namespace ArrayType
variable {numElems : Nat}

/-- The number of elements in this type. -/
def size (self : ArrayType α numElems) := numElems

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element type
  and size are valid.
-/
def getRef [ToTypeRef α] (self : ArrayType α numElems) : LLVM TypeRef := do
  getArrayTypeRef (← toTypeRef self.elementType) self.size.toUInt64

end ArrayType

instance [ToTypeRef α] {numElems} : ToTypeRef (ArrayType α numElems) :=
  ⟨ArrayType.getRef⟩
