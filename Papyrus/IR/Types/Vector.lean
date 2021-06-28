import Papyrus.IR.TypeRefs

namespace Papyrus

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
