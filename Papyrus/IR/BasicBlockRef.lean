import Papyrus.Context
import Papyrus.IR.ValueRef
import Papyrus.IR.InstructionRef

namespace Papyrus

/--
  A reference to an external LLVM
  [BasicBlock](https://llvm.org/doxygen/classllvm_1_1BasicBlock.html).
-/
structure BasicBlockRef extends ValueRef where
  is_basic_block : toValueRef.valueKind = ValueKind.basicBlock

instance : Coe BasicBlockRef ValueRef := ⟨(·.toValueRef)⟩

namespace BasicBlockRef

/-- Cast a general `ValueRef` to a `BasicBlockRef` given proof it is one. -/
def cast (val : ValueRef) (h : val.valueKind = ValueKind.basicBlock) : BasicBlockRef :=
  {toValueRef := val, is_basic_block := h}

/-- Create a new unlinked basic block with given label/name (or none if empty). -/
@[extern "papyrus_basic_block_create"]
constant create (name : @& String := "") : LlvmM BasicBlockRef

/-- Get the array of references to the instructions of this basic block. -/
@[extern "papyrus_basic_block_get_instructions"]
constant getInstructions (self : @& BasicBlockRef) : IO (Array InstructionRef)

/-- Add an instruction to the end of the basic block. -/
@[extern "papyrus_basic_block_append_instruction"]
constant appendInstruction (inst : @& InstructionRef) (self : @& BasicBlockRef) : IO PUnit
