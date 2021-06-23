import Papyrus.Context
import Papyrus.Types.TypeID

namespace Papyrus

/-- A reference to the LLVM representation of a Type. -/
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
