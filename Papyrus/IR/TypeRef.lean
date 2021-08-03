import Papyrus.FFI
import Papyrus.Context
import Papyrus.IR.TypeID

namespace Papyrus

/--
  An opaque type representing and external LLVM
  [Type](https://llvm.org/doxygen/classllvm_1_1Type.html).
-/
constant Llvm.Type : Type := Unit

/--
  A reference to an external LLVM
  [Type](https://llvm.org/doxygen/classllvm_1_1Type.html).
-/
def TypeRef := LinkedLoosePtr ContextRef Llvm.Type

namespace TypeRef

/-- Get the `TypeID` of this type. -/
@[extern "papyrus_type_get_id"]
constant getTypeID (self : TypeRef) : IO TypeID

/-- Get the owning LLVM context of this type. -/
@[extern "papyrus_type_get_context"]
constant getContext (self : TypeRef) : IO ContextRef

end TypeRef
