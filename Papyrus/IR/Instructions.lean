import Papyrus.Context
import Papyrus.IR.Value

namespace Papyrus

/--
  An external reference to the LLVM representation of an
  [Instruction](https://llvm.org/doxygen/classllvm_1_1Instruction.html).
-/
def InstructionRef := UserRef

/--
  An external reference to the LLVM representation of a
  [ReturnInst](https://llvm.org/doxygen/classllvm_1_1ReturnInst.html).
-/
def ReturnInstRef := InstructionRef

namespace ReturnInstRef

/-- Create a new unlinked return instruction. -/
@[extern "papyrus_create_return_inst"]
constant create (retVal : @& Option ValueRef := none) : LLVM ReturnInstRef

/-- Get a reference to the returned value. -/
@[extern "papyrus_return_inst_get_value"]
constant getReturnValue (self : @& ReturnInstRef) : IO (Option ValueRef)

end ReturnInstRef
