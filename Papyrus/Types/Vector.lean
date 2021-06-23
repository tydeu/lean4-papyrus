import Papyrus.Types.TypeRef

namespace Papyrus

/-- A SIMD vector type. -/
structure VectorType (α) (elemQuant : Nat) (scalable : Bool) where
  elementType : α

/-- A vector type of the given type with the given size and scalability. -/
def vectorType (elemType : α) (elemQuant : Nat) (scalable : Bool) :=
  (VectorType.mk elemType : VectorType α elemQuant scalable)

/-- A fixed-length SIMD vector type. -/
abbrev FixedVectorType (α) (elemQuant : Nat) := VectorType α elemQuant false

/-- A vector type of the given type with the given fixed size. -/
def fixedVectorType (elemType : α) (elemQuant : Nat) : FixedVectorType α elemQuant :=
  vectorType elemType elemQuant false

/-- A scalable SIMD vector type. -/
abbrev ScalableVectorType (α) (elemQuant : Nat) := VectorType α elemQuant true

/-- A scalable vector type of the given type with the given minimum size. -/
def scalableVectorType (elemType : α) (elemQuant : Nat) : ScalableVectorType α elemQuant :=
  vectorType elemType elemQuant true

@[extern "papyrus_get_vector_type"]
private constant getVectorTypeRef
  (elemType : @& TypeRef) (elemQuant : UInt32) (scalable : Bool) : IO TypeRef

namespace VectorType
variable {elemQuant : Nat} {scalable : Bool}

/--
  The element quanntity of the vector.
  For non-scalable vectors, this is exactly this number of elements.
  For scalable vectors, there is a runtime multiple of this number.
-/
def elementQuantuty (self : VectorType α elemQuant scalable) := elemQuant

/- Is this a scalable vector type? -/
def isScalable (self : VectorType α elemQuant scalable) := scalable

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element type, size,
  and scalability are valid.
-/
def getRef [ToTypeRef α] (self : VectorType α elemQuant scalable) : LLVM TypeRef := do
  getVectorTypeRef (← toTypeRef self.elementType) elemQuant.toUInt32 scalable

end VectorType

instance [ToTypeRef α] {elemQuant} {scalable} : ToTypeRef (VectorType α elemQuant scalable) :=
  ⟨VectorType.getRef⟩
