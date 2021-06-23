import Papyrus.Types.TypeRef

namespace Papyrus

-- # Fixed Vector Type

/-- A fixed-length homogenous vector type. -/
structure FixedVectorType (α) (numElems : Nat) where
  elementType : α

@[extern "papyrus_get_fixed_vector_type"]
private constant getFixedVectorTypeRef
  (elemType : @& TypeRef) (numElems : UInt32) : IO TypeRef

-- # Scalable Vector Type

/-- A scalable homogenous vector type. -/
structure ScalableVectorType (α) (minNumElems : Nat) where
  elementType : α

@[extern "papyrus_get_scalable_vector_type"]
private constant getScalableVectorTypeRef
  (elemType : @& TypeRef) (minNumElems : UInt32) : IO TypeRef
