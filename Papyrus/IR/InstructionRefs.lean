import Papyrus.Context
import Papyrus.IR.ValueRef
import Papyrus.IR.InstructionRef

namespace Papyrus

/--
  A reference to an external LLVM
  [ReturnInst](https://llvm.org/doxygen/classllvm_1_1ReturnInst.html).
-/
def ReturnInstRef := InstructionRef

namespace ReturnInstRef

/-- Create a new unlinked return instruction. -/
@[extern "papyrus_return_inst_create"]
constant create (retVal : @& ValueRef) : LLVM ReturnInstRef

/-- Create a new unlinked empty return instruction. -/
@[extern "papyrus_return_inst_create_empty"]
constant createEmpty : LLVM ReturnInstRef

/-- Get a reference to the returned value. -/
@[extern "papyrus_return_inst_get_value"]
constant getReturnValue (self : @& ReturnInstRef) : IO (Option ValueRef)

end ReturnInstRef
