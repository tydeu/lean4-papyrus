import Papyrus.Context
import Papyrus.IR.TypeID

namespace Papyrus

/--
  A reference to the LLVM representation of a
  [Type](https://llvm.org/doxygen/classllvm_1_1Type.html).
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
