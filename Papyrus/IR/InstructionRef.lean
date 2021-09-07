import Papyrus.Context
import Papyrus.IR.ValueRef
import Papyrus.IR.ValueKind
import Papyrus.IR.InstructionKind

namespace Papyrus

/--
  A reference to an external LLVM
  [Instruction](https://llvm.org/doxygen/classllvm_1_1Instruction.html).
-/
def InstructionRef := UserRef

namespace InstructionRef

def getOpcode (self : InstructionRef) : IO UInt32 :=
  (· - ValueKind.instruction.toValueID) <$> self.getValueID

def getInstructionKind (self : InstructionRef) : IO InstructionKind :=
  InstructionKind.ofOpcode! <$> self.getOpcode
