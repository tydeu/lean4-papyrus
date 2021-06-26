import Papyrus.IR.Types.TypeRef

namespace Papyrus

-- # Vector Type References

/--
  A reference to the LLVM representation of a
  [VectorType](https://llvm.org/doxygen/classllvm_1_1VectorType.html).
-/
def VectorTypeRef := TypeRef

namespace VectorTypeRef

/--
  Get a reference to the LLVM vector type of
    the given element type, element quantity, and scalability.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_vector_type"]
constant get (elemType : @& TypeRef) (elemQuant : UInt32)
  (isScalable := false) : IO VectorTypeRef

/-- Get a reference to the element type of this vector type. -/
@[extern "papyrus_vector_type_get_element_type"]
constant getElementType (self : @& VectorTypeRef) : IO TypeRef

/-- Get the raw minimum number of elemnts of this vector type. -/
@[extern "papyrus_vector_type_get_element_quantity"]
constant getRawMinSize (self : @& VectorTypeRef) : IO UInt32

/--
  Get the minimum number of elemnts of this vector type (as a `Nat`).
  For non-scalable vectors, this is exactly this number of elements.
  For scalable vectors, there is a runtime multiple of this number.
-/
@[extern "papyrus_vector_type_get_element_quantity"]
constant getMinSize (self : @& VectorTypeRef) : IO Nat

/-- Get whether this vector type is scalable. -/
@[extern "papyrus_vector_type_is_scalable"]
constant isScalable (self : @& VectorTypeRef) : IO Bool

end VectorTypeRef

/--
  A reference to the LLVM representation of a
  [FixedVectorType](https://llvm.org/doxygen/classllvm_1_1FixedVectorType.html).
-/
def FixedVectorTypeRef := VectorTypeRef

namespace FixedVectorTypeRef

/-- Get the raw number of elements in this vector type. -/
def getRawSize (self : @& FixedVectorTypeRef) :=
  VectorTypeRef.getRawMinSize self

/-- Get the number of elements in this vector type (as a `Nat`).. -/
def getSize (self : @& FixedVectorTypeRef) :=
  VectorTypeRef.getMinSize self

end FixedVectorTypeRef

/--
  A reference to the LLVM representation of a
  [ScalableVectorType](https://llvm.org/doxygen/classllvm_1_1ScalableVectorType.html).
-/
def ScalableVectorTypeRef := VectorTypeRef

-- # Pure Vector Types

/-- A SIMD vector type. -/
structure VectorType (α) (elemQuant : Nat) (scalable : Bool) where
  elementType : α

/-- A vector type of the given type with the given size and scalability. -/
def vectorType (elemType : α) (elemQuant : Nat) (scalable : Bool) :=
  (VectorType.mk elemType : VectorType α elemQuant scalable)

namespace VectorType
variable {elemQuant : Nat} {scalable : Bool}

/--
  The minimum number of elements of the vector.
  For non-scalable vectors, this is exactly this number of elements.
  For scalable vectors, there is a runtime multiple of this number.
-/
def minSize (self : VectorType α elemQuant scalable) := elemQuant

/- Is this a scalable vector type? -/
def isScalable (self : VectorType α elemQuant scalable) := scalable

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element type, size,
  and scalability are valid.
-/
def getRef [ToTypeRef α] (self : VectorType α elemQuant scalable) : LLVM VectorTypeRef := do
  VectorTypeRef.get (← toTypeRef self.elementType) elemQuant.toUInt32 scalable

end VectorType

instance [ToTypeRef α] {elemQuant} {scalable} : ToTypeRef (VectorType α elemQuant scalable) :=
  ⟨VectorType.getRef⟩

-- # Fixed Vector Type

/-- A fixed-length SIMD vector type. -/
abbrev FixedVectorType (α) (numElems : Nat) := VectorType α numElems false

/-- A vector type of the given type with the given fixed size. -/
def fixedVectorType (elemType : α) (numElems : Nat) : FixedVectorType α numElems :=
  vectorType elemType numElems false

namespace FixedVectorType
variable {numElems : Nat}

/-- The number of elements in this type. -/
def size (self :  FixedVectorType α numElems) := numElems

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element type
    and size are valid.
-/
def getRef [ToTypeRef α] (self : FixedVectorType α numElems) : LLVM FixedVectorTypeRef :=
  VectorType.getRef self

end FixedVectorType

-- # Scalable Vector Type

/-- A scalable SIMD vector type. -/
abbrev ScalableVectorType (α) (minNumElms : Nat) := VectorType α minNumElms true

/-- A scalable vector type of the given type with the given minimum size. -/
def scalableVectorType (elemType : α) (minNumElms : Nat) : ScalableVectorType α minNumElms :=
  vectorType elemType minNumElms true

namespace ScalableVectorType
variable {minNumElems : Nat}

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element type
    and minimum size are valid.
-/
def getRef [ToTypeRef α] (self : ScalableVectorType α minNumElems) : LLVM ScalableVectorTypeRef :=
  VectorType.getRef self

end ScalableVectorType
