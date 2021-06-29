import Papyrus.Context
import Papyrus.IR.ValueRef
import Papyrus.IR.InstructionRef

namespace Papyrus

/--
  An external reference to the LLVM representation of a
  [BasicBlock](https://llvm.org/doxygen/classllvm_1_1BasicBlock.html).
-/
def BasicBlockRef := ValueRef

namespace BasicBlockRef

/-- Create a new unlinked basic block with given label/name (or none if empty). -/
@[extern "papyrus_create_basic_block"]
constant create (name : @& String) : LLVM BasicBlockRef

/-- Get the array of references to the instructions of this basic block. -/
@[extern "papyrus_basic_block_get_instructions"]
constant getInstructions (self : @& BasicBlockRef) : IO (Array InstructionRef)

/-- Add an instruction to the end of the basic block. -/
@[extern "papyrus_basic_block_append_instruction"]
constant appendInstruction (inst : @& InstructionRef) (self : @& BasicBlockRef) : IO PUnit

end BasicBlockRef
