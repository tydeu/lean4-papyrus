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
  A reference to an external LLVM
  [UnaryInstruction](https://llvm.org/doxygen/classllvm_1_1UnaryInstruction.html).
-/
structure UnaryInstructionRef extends InstructionRef
instance : Coe UnaryInstructionRef InstructionRef := ⟨(·.toInstructionRef)⟩

--------------------------------------------------------------------------------
-- # Return
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [ReturnInst](https://llvm.org/doxygen/classllvm_1_1ReturnInst.html).
-/
structure ReturnInstRef extends InstructionRef where
  is_return_inst : toInstructionRef.instructionKind = InstructionKind.ret

instance : Coe ReturnInstRef InstructionRef := ⟨(·.toInstructionRef)⟩

namespace ReturnInstRef

/-- Cast a general `InstructionRef` to a `ReturnInstRef` given proof it is one. -/
def castInst (inst : InstructionRef) (h : inst.instructionKind = InstructionKind.ret) : ReturnInstRef :=
  {toInstructionRef := inst, is_return_inst := h}

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
structure BranchInstRef extends InstructionRef where
  is_branch_inst : toInstructionRef.instructionKind = InstructionKind.branch

instance : Coe BranchInstRef InstructionRef := ⟨(·.toInstructionRef)⟩

namespace BranchInstRef

/-- Cast a general `InstructionRef` to a `BranchInstRef` given proof it is one. -/
def castInst (inst : InstructionRef) (h : inst.instructionKind = InstructionKind.branch) : BranchInstRef :=
  {toInstructionRef := inst, is_branch_inst := h}

/-- Get whether this branch instruction is conditional. -/
@[extern "papyrus_branch_inst_is_conditional"]
constant isConditional (self : @& BranchInstRef) : Bool

/-- Get the possible jump targets of this branch instruction. -/
@[extern "papyrus_branch_inst_get_successors"]
constant getSuccessors (self : @& BranchInstRef) : IO (Array BasicBlockRef)

end BranchInstRef

/-- A reference to a conditional `BranchInst`. -/
structure CondBrInstRef extends BranchInstRef where
  is_conditional : toBranchInstRef.isConditional = true

instance : Coe CondBrInstRef BranchInstRef := ⟨(·.toBranchInstRef)⟩

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

/-- A reference to an unconditional `BranchInst`. -/
structure BrInstRef extends BranchInstRef where
  is_unconditional : toBranchInstRef.isConditional ≠ true

instance : Coe BrInstRef BranchInstRef := ⟨(·.toBranchInstRef)⟩

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
structure LoadInstRef extends UnaryInstructionRef where
  is_load_inst : toInstructionRef.instructionKind = InstructionKind.load

instance : Coe LoadInstRef UnaryInstructionRef := ⟨(·.toUnaryInstructionRef)⟩

namespace LoadInstRef

/-- Cast a general `InstructionRef` to a `LoadInstRef` given proof it is one. -/
def castInst (inst : InstructionRef) (h : inst.instructionKind = InstructionKind.load) : LoadInstRef :=
  {toInstructionRef := inst, is_load_inst := h}

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
structure StoreInstRef extends InstructionRef where
  is_store_inst : toInstructionRef.instructionKind = InstructionKind.store

instance : Coe StoreInstRef InstructionRef := ⟨(·.toInstructionRef)⟩

namespace StoreInstRef

/-- Cast a general `InstructionRef` to a `StoreInstRef` given proof it is one. -/
def castInst (inst : InstructionRef) (h : inst.instructionKind = InstructionKind.store) : StoreInstRef :=
  {toInstructionRef := inst, is_store_inst := h}

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
structure GetElementPtrInstRef extends InstructionRef where
  is_get_element_ptr_inst : toInstructionRef.instructionKind = InstructionKind.getElementPtr

instance : Coe GetElementPtrInstRef InstructionRef := ⟨(·.toInstructionRef)⟩

namespace GetElementPtrInstRef

/-- Cast a general `InstructionRef` to a `GetElementPtrInstRef` given proof it is one. -/
def castInst (inst : InstructionRef) (h : inst.instructionKind = InstructionKind.getElementPtr) : GetElementPtrInstRef :=
  {toInstructionRef := inst, is_get_element_ptr_inst := h}

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
constant createInbounds (pointeeType : @& TypeRef) (ptr : @& ValueRef)
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
structure CallBaseRef extends InstructionRef
instance : Coe CallBaseRef InstructionRef := ⟨(·.toInstructionRef)⟩

/--
  A reference to an external LLVM
  [CallInst](https://llvm.org/doxygen/classllvm_1_1CallInst.html).
-/
structure CallInstRef extends CallBaseRef where
  is_call_inst : toInstructionRef.instructionKind = InstructionKind.call

instance : Coe CallInstRef CallBaseRef := ⟨(·.toCallBaseRef)⟩

namespace CallInstRef

/-- Cast a general `InstructionRef` to a `CallInstRef` given proof it is one. -/
def castInst (inst : InstructionRef) (h : inst.instructionKind = InstructionKind.call) : CallInstRef :=
  {toInstructionRef := inst, is_call_inst := h}

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
  CallInstRef.create (← self.getFunctionType) self args name

end FunctionRef

--------------------------------------------------------------------------------
-- # Binary Operators
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [Binary Operator](https://llvm.org/doxygen/classllvm_1_1BinaryOperator.html).
-/
structure  BinaryOperatorRef extends InstructionRef
instance : Coe BinaryOperatorRef InstructionRef := ⟨(·.toInstructionRef)⟩

namespace BinaryOperatorRef
/-- Create a new binary instruction, given the opcode and the two operands.  -/
@[extern "papyrus_binary_operator_create"]
constant create (op : InstructionKind) (s1 : @& ValueRef) (s2 : @& ValueRef) (name : @& String := "") (h : op.is_binary_op := by trivial) : IO BinaryOperatorRef
end BinaryOperatorRef