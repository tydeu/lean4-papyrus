import Papyrus.Context
import Papyrus.IR.Align
import Papyrus.IR.ValueRef
import Papyrus.IR.InstructionRef
import Papyrus.IR.TypeRefs
import Papyrus.IR.ConstantRefs
import Papyrus.IR.FunctionRef
import Papyrus.IR.InstructionModifiers

namespace Papyrus

/--
  A reference to an external LLVM User.
  See https://llvm.org/doxygen/classllvm_1_1UnaryInstruction.html.
-/
def UnaryInstructionRef := InstructionRef

--------------------------------------------------------------------------------
-- # Return
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [ReturnInst](https://llvm.org/doxygen/classllvm_1_1ReturnInst.html).
-/
def ReturnInstRef := InstructionRef

namespace ReturnInstRef

/-- Create a new unlinked void return instruction. -/
@[extern "papyrus_return_inst_create_void"]
constant createVoid : LlvmM ReturnInstRef

/-- Create a new unlinked return instruction. -/
@[extern "papyrus_return_inst_create"]
constant create (retVal : @& ValueRef) : LlvmM ReturnInstRef

/-- Create a new unlinked i1 return instruction. -/
def createBool (retVal : Bool) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofBool retVal)

/-- Create a new unlinked i8 return instruction. -/
def createUInt8 (retVal : UInt8) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofUInt8 retVal)

/-- Create a new unlinked i16 return instruction. -/
def createUInt16 (retVal : UInt16) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofUInt16 retVal)

/-- Create a new unlinked i32 return instruction. -/
def createUInt32 (retVal : UInt32) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofUInt32 retVal)

/-- Create a new unlinked i64 return instruction. -/
def createUInt64 (retVal : UInt64) : LlvmM ReturnInstRef := do
  create (← ConstantIntRef.ofUInt64 retVal)

/-- Get a reference to the returned value. -/
@[extern "papyrus_return_inst_get_value"]
constant getReturnValue (self : @& ReturnInstRef) : IO (Option ValueRef)

end ReturnInstRef

--------------------------------------------------------------------------------
-- # Branch
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [BranchInst](https://llvm.org/doxygen/classllvm_1_1BranchInst.html).
-/
def BranchInstRef := InstructionRef

namespace BranchInstRef

/-- Get whether this branch instruction is conditional. -/
@[extern "papyrus_branch_inst_is_conditional"]
constant isConditional (self : @& BranchInstRef) : IO Bool

/-- Get the possible jump targets of this branch instruction. -/
@[extern "papyrus_branch_inst_get_successors"]
constant getSuccessors (self : @& BranchInstRef) : IO (Array BasicBlockRef)

end BranchInstRef

/-- A reference to a conditional `BranchInst`. -/
def CondBrInstRef := BranchInstRef

namespace CondBrInstRef

/-- Create a new conditional `br` instruction. -/
@[extern "papyrus_branch_inst_create"]
constant create (ifTrue : @& BasicBlockRef) (ifFalse : @& BasicBlockRef)
  (cond : @& ValueRef) : IO CondBrInstRef

/-- Get the branch condition of this instruction. -/
@[extern "papyrus_branch_inst_get_condition"]
constant getCondition (self : @& CondBrInstRef) : IO ValueRef

/-- Set the branch condition of this instruction. -/
@[extern "papyrus_branch_inst_set_condition"]
constant setCondition (cond : @& ValueRef) (self : @& CondBrInstRef) : IO PUnit

/-- Get the basic block to jump to if true. -/
@[extern "papyrus_branch_inst_get_successor0"]
constant getIfTrue (self : @& CondBrInstRef) : IO BasicBlockRef

/-- Set the basic block to jump to if true. -/
@[extern "papyrus_branch_inst_set_successor0"]
constant setIfTrue (bb : @& BasicBlockRef) (self : @& CondBrInstRef) : IO PUnit

/-- Get the basic block to jump to if false. -/
@[extern "papyrus_branch_inst_get_successor1"]
constant getIfFalse (self : @& CondBrInstRef) : IO BasicBlockRef

/-- Set the basic block to jump to if false. -/
@[extern "papyrus_branch_inst_set_successor1"]
constant setIfFalse (bb : @& BasicBlockRef) (self : @& CondBrInstRef) : IO PUnit

/-- Swap the basic block to jump to (i.e., if true becomes if false and vice versa). -/
@[extern "papyrus_branch_inst_swap_successors"]
constant swapSuccessors (self : @& CondBrInstRef) : IO PUnit

end CondBrInstRef

/-- A reference to a unconditional `BranchInst`. -/
def BrInstRef := BranchInstRef

namespace BrInstRef

/-- Create a new unconditional `br` instruction (i.e., a jump). -/
@[extern "papyrus_branch_inst_create_jump"]
constant create (bb : @& BasicBlockRef) : IO BrInstRef

/-- Get the basic block to jump to. -/
@[extern "papyrus_branch_inst_get_successor0"]
constant getSuccessor (self : @& BrInstRef) : IO BasicBlockRef

/-- Set the basic block to jump to. -/
@[extern "papyrus_branch_inst_set_successor0"]
constant setSuccessor (bb : @& BasicBlockRef) (self : @& BrInstRef) : IO PUnit

end BrInstRef

--------------------------------------------------------------------------------
-- # Load
--------------------------------------------------------------------------------


/--
  A reference to an external LLVM
  [LoadInst](https://llvm.org/doxygen/classllvm_1_1LoadInst.html).
-/
def LoadInstRef := InstructionRef

namespace LoadInstRef

/-- Create a new `load` instruction. -/
@[extern "papyrus_load_inst_create"]
constant create (type : @& TypeRef) (ptr : @& ValueRef)
  (name : @& String := "") (isVolatile := false) (align : Align := 1)
  (order := AtomicOrdering.notAtomic) (ssid := SyncScopeID.system)
  : IO LoadInstRef

/-- Get a reference to pointer value being loaded from. -/
@[extern "papyrus_load_inst_get_pointer_operand"]
constant getPointerOperand (self : @& LoadInstRef) : IO ValueRef

/-- Get whether this `store` is to a volatile memory location. -/
@[extern "papyrus_load_inst_get_volatile"]
constant getVolatile (self : @& LoadInstRef) : IO Bool

/-- Set whether this `store` is volatile. -/
@[extern "papyrus_load_inst_set_volatile"]
constant setVolatile (volatile : Bool) (self : @& LoadInstRef) : IO PUnit

/-- Get the alignment of the memory access being preformed. -/
@[extern "papyrus_load_inst_get_align"]
constant getAlign (self : @& LoadInstRef) : IO Align

/-- Set the alignment of the memory access being preformed. -/
@[extern "papyrus_load_inst_set_align"]
constant setAlign (align : Align) (self : @& LoadInstRef) : IO PUnit

/-- Get the ordering constraint of this load. -/
@[extern "papyrus_load_inst_get_ordering"]
constant getOrdering (self : @& LoadInstRef) : IO AtomicOrdering

/-- Set the ordering constraint of this load. -/
@[extern "papyrus_load_inst_set_ordering"]
constant setOrdering (ordering : AtomicOrdering) (self : @& LoadInstRef) : IO PUnit

/-- Get the synchronization scope ID of this load. -/
@[extern "papyrus_load_inst_get_sync_scope_id"]
constant getSyncScopeID (self : @& LoadInstRef) : IO SyncScopeID

/-- Set the synchronization scope ID of this load. -/
@[extern "papyrus_load_inst_set_sync_scope_id"]
constant setSyncScopeID (ssid : SyncScopeID) (self : @& LoadInstRef) : IO PUnit

/-- Set the ordering constraint and the synchronization scope ID of this load. -/
@[extern "papyrus_load_inst_set_atomic"]
constant setAtomic (ordering : AtomicOrdering) (ssd : SyncScopeID := SyncScopeID.system)
  (self : @& LoadInstRef) : IO PUnit

end LoadInstRef

--------------------------------------------------------------------------------
-- # Store
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [StoreInst](https://llvm.org/doxygen/classllvm_1_1StoreInst.html).
-/
def StoreInstRef := InstructionRef

namespace StoreInstRef

/-- Create a new `store` instruction. -/
@[extern "papyrus_store_inst_create"]
constant create (val : @& ValueRef) (ptr : @& ValueRef)
  (isVolatile := false) (align : Align := 1)
  (order := AtomicOrdering.notAtomic) (ssid := SyncScopeID.system)
  : IO StoreInstRef

/-- Get a reference to value being stored. -/
@[extern "papyrus_store_inst_get_value_operand"]
constant getValueOperand (self : @& StoreInstRef) : IO ValueRef

/-- Get a reference to pointer value being stored to. -/
@[extern "papyrus_store_inst_get_pointer_operand"]
constant getPointerOperand (self : @& StoreInstRef) : IO ValueRef

/-- Get whether this `store` is to a volatile memory location. -/
@[extern "papyrus_store_inst_get_volatile"]
constant getVolatile (self : @& StoreInstRef) : IO Bool

/-- Set whether this `store` is volatile. -/
@[extern "papyrus_store_inst_set_volatile"]
constant setVolatile (volatile : Bool) (self : @& StoreInstRef) : IO PUnit

/-- Get the alignment of the memory access being preformed. -/
@[extern "papyrus_store_inst_get_align"]
constant getAlign (self : @& StoreInstRef) : IO Align

/-- Set the alignment of the memory access being preformed. -/
@[extern "papyrus_store_inst_set_align"]
constant setAlign (align : Align) (self : @& StoreInstRef) : IO PUnit

/-- Get the ordering constraint of this store. -/
@[extern "papyrus_store_inst_get_ordering"]
constant getOrdering (self : @& StoreInstRef) : IO AtomicOrdering

/-- Set the ordering constraint of this store. -/
@[extern "papyrus_store_inst_set_ordering"]
constant settOrdering (ordering : AtomicOrdering) (self : @& StoreInstRef) : IO PUnit

/-- Get the synchronization scope ID of this store. -/
@[extern "papyrus_store_inst_get_sync_scope_id"]
constant getSyncScopeID (self : @& StoreInstRef) : IO SyncScopeID

/-- Set the synchronization scope ID of this store. -/
@[extern "papyrus_store_inst_set_sync_scope_id"]
constant setSyncScopeID (ssid : SyncScopeID) (self : @& StoreInstRef) : IO PUnit

/-- Set the ordering constraint and the synchronization scope ID of this store. -/
@[extern "papyrus_store_inst_set_atomic"]
constant setAtomic (ordering : AtomicOrdering) (ssd : SyncScopeID := SyncScopeID.system)
  (self : @& StoreInstRef) : IO PUnit

end StoreInstRef

--------------------------------------------------------------------------------
-- # GetElementPtr
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [GetElementPtrInst](https://llvm.org/doxygen/classllvm_1_1GetElementPtrInst.html).
-/
def GetElementPtrInstRef := InstructionRef

namespace GetElementPtrInstRef

/-- Create a new `getelementptr` instruction. -/
@[extern "papyrus_getelementptr_inst_create"]
constant create (pointeeType : @& TypeRef) (ptr : @& ValueRef)
  (indices : @& Array ValueRef) (name : @& String := "") : IO GetElementPtrInstRef

/--
  Create a new `getelementptr inbounds` instruction.

  With the `inbounds` keyword, the result of the GEP is a poison value
  if certain rules are violated.

  See the [section](https://llvm.org/docs/LangRef.html#id233) on the GEP
  instruction in LLVM Language Reference Manual for more details.
-/
@[extern "papyrus_getelementptr_inst_create_inbounds"]
constant createInbounds (pointeeType : @& PointerTypeRef) (ptr : @& ValueRef)
  (indices : @& Array ValueRef) (name : @& String := "") : IO GetElementPtrInstRef

/-- Get a reference to the subject of this GEP instruction. -/
@[extern "papyrus_getelementptr_inst_get_pointer_operand"]
constant getPointerOperand (self : @& GetElementPtrInstRef) : IO ValueRef

/-- Get array of reference to this GEP instruction's indices. -/
@[extern "papyrus_getelementptr_inst_get_indices"]
constant getIndices (self : @& GetElementPtrInstRef) : IO (Array ValueRef)

/-- Get whether this GEP instruction has the `inbounds` flag set. -/
@[extern "papyrus_getelementptr_inst_get_inbounds"]
constant getInbounds (self : @& GetElementPtrInstRef) : IO Bool

/-- Set whether this GEP instruction has the `inbounds` flag. -/
@[extern "papyrus_getelementptr_inst_set_inbounds"]
constant setInbounds (inbounds := true) (self : @& GetElementPtrInstRef) : IO PUnit

end GetElementPtrInstRef

--------------------------------------------------------------------------------
-- # Call
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [CallBase](https://llvm.org/doxygen/classllvm_1_1CallBase.html).
-/
def CallBaseRef := InstructionRef

/--
  A reference to an external LLVM
  [CallInst](https://llvm.org/doxygen/classllvm_1_1CallInst.html).
-/
def CallInstRef := CallBaseRef

namespace CallInstRef

/-- Create a new unlinked call instruction. -/
@[extern "papyrus_call_inst_create"]
constant create (type : @& FunctionTypeRef) (fn : @& ValueRef) (args : @& Array ValueRef)
  (name : @& String := "") : IO CallInstRef

end CallInstRef

namespace FunctionRef

/-- Create an unlinked call instruction that invokes this function. -/
def createCall
(args : @& Array ValueRef) (self : @& FunctionRef) (name : @& String := "")
: IO CallInstRef := do
  CallInstRef.create (← self.getType) self args name

end FunctionRef
