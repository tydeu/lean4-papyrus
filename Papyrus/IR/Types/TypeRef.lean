import Papyrus.Context
import Papyrus.IR.Types.TypeID

namespace Papyrus

/--
  A reference to the LLVM representation of a Type.
  See https://llvm.org/doxygen/classllvm_1_1Type.html.
-/
constant TypeRef : Type := Unit

namespace TypeRef

/-- Get the `TypeID` of this type. -/
@[extern "papyrus_type_get_id"]
constant getTypeID (self : TypeRef) : IO TypeID

/-- Get the owning LLVM context of this type. -/
@[extern "papyrus_type_get_context"]
constant getContext (self : TypeRef) : IO ContextRef

end TypeRef

/-- General class for retrieving LLVM type representations. -/
class ToTypeRef (α) where
  toTypeRef : α → LLVM TypeRef

export ToTypeRef (toTypeRef)

/-- General class for retrieving arrays of LLVM type representations. -/
class ToTypeRefArray (α : Type) where
  toTypeRefArray : α → LLVM (Array TypeRef)

export ToTypeRefArray (toTypeRefArray)

instance [ToTypeRef α] : ToTypeRefArray α where
  toTypeRefArray a := do #[← toTypeRef a]

instance [ToTypeRef α] : ToTypeRefArray (Array α) where
  toTypeRefArray := Array.mapM toTypeRef

instance [ToTypeRefArray α] [ToTypeRefArray β] : ToTypeRefArray (α × β) where
  toTypeRefArray p := do pure <| (← toTypeRefArray p.1) ++ (← toTypeRefArray p.2)
