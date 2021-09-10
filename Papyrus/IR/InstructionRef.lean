import Papyrus.Context
import Papyrus.IR.ValueRef
import Papyrus.IR.ValueKind
import Papyrus.IR.InstructionKind

namespace Papyrus

/--
  A reference to an external LLVM
  [Instruction](https://llvm.org/doxygen/classllvm_1_1Instruction.html).
-/
structure InstructionRef extends UserRef where
  is_instruction : toValueRef.valueKind = ValueKind.instruction

instance : Coe InstructionRef UserRef := ⟨(·.toUserRef)⟩

namespace InstructionRef

def cast (val : ValueRef) (h : val.valueKind = ValueKind.instruction) : InstructionRef :=
  {toValueRef := val, is_instruction := h}

def opcode (self : InstructionRef) : UInt32 :=
  (· - ValueKind.instruction.toValueID) self.valueID

def instructionKind (self : InstructionRef) : InstructionKind :=
  InstructionKind.ofOpcode! self.opcode
