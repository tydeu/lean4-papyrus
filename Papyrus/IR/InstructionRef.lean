import Papyrus.Context
import Papyrus.IR.ValueRef

namespace Papyrus

/--
  An external reference to the LLVM representation of an
  [Instruction](https://llvm.org/doxygen/classllvm_1_1Instruction.html).
-/
def InstructionRef := UserRef
