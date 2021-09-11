import Papyrus

open Papyrus

def assertEq [Repr α] [DecidableEq α]
(expected actual : α) : IO (PLift (expected = actual)) := do
  if h : expected = actual then return PLift.up h else
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
  unless expected == actual do
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

-- void `ret`
#eval LlvmM.run do
  let inst ← ReturnInstRef.createVoid
  assertBEq ValueKind.instruction inst.valueKind
  assertBEq InstructionKind.ret inst.instructionKind
  unless (← inst.getReturnValue).isNone do
    throw <| IO.userError "got return value when expecting none"

-- non-void `ret`
#eval LlvmM.run do
  let val := 1
  let intTypeRef ← IntegerTypeRef.get 32
  let const ← intTypeRef.getConstantInt val
  let inst ← ReturnInstRef.create const
  assertBEq ValueKind.instruction inst.valueKind
  assertBEq InstructionKind.ret inst.instructionKind
  let some retVal ← inst.getReturnValue
    |  throw <| IO.userError "got unexpected void return"
  let ⟨h⟩ ← assertEq ValueKind.constantInt retVal.valueKind
  let retVal := ConstantIntRef.cast retVal h.symm
  let retInt ← ConstantIntRef.getIntValue retVal
  assertBEq val retInt

-- conditional `br`
#eval LlvmM.run do
  let name0 := "foo"
  let name1 := "bar"
  let bb0 ← BasicBlockRef.create name0
  let bb1 ← BasicBlockRef.create name1
  let inst ← CondBrInstRef.create bb0 bb1 (← ConstantIntRef.ofBool true)
  assertBEq ValueKind.instruction inst.valueKind
  assertBEq InstructionKind.branch inst.instructionKind
  assertBEq true inst.isConditional
  let cond  ← inst.getCondition
  let ⟨h⟩ ← assertEq ValueKind.constantInt cond.valueKind
  let cond := ConstantIntRef.cast cond h.symm
  assertBEq 1 (← cond.getNatValue)
  let succ0 ← inst.getIfTrue
  assertBEq name0 (← succ0.getName)
  let succ1 ← inst.getIfFalse
  assertBEq name1 (← succ1.getName)

-- unconditional `br`
#eval LlvmM.run do
  let name := "foo"
  let bb ← BasicBlockRef.create name
  let inst ← BrInstRef.create bb
  assertBEq ValueKind.instruction inst.valueKind
  assertBEq InstructionKind.branch inst.instructionKind
  assertBEq false inst.isConditional
  let succ ← inst.getSuccessor
  assertBEq name (← succ.getName)

-- simple `load`
#eval LlvmM.run do
  let i64Ty ← int64Type.getRef
  let i64pTy ← PointerTypeRef.get i64Ty
  let nullptr ← i64pTy.getNullConstant
  let inst ← LoadInstRef.create i64Ty nullptr
  assertBEq ValueKind.instruction inst.valueKind
  assertBEq InstructionKind.load inst.instructionKind
  let op ← inst.getPointerOperand
  assertBEq ValueKind.constantPointerNull op.valueKind
  assertBEq false (← inst.getVolatile)
  assertBEq 1 (← inst.getAlign)
  assertBEq AtomicOrdering.notAtomic (← inst.getOrdering)
  assertBEq SyncScopeID.system (← inst.getSyncScopeID)

-- simple `store`
#eval LlvmM.run do
  let n ← ConstantIntRef.ofUInt64 1
  let i64pTy ← int64Type.pointerType.getRef
  let nullptr ← i64pTy.getNullConstant
  let inst ← StoreInstRef.create n nullptr
  assertBEq ValueKind.instruction inst.valueKind
  assertBEq InstructionKind.store inst.instructionKind
  let op ← inst.getValueOperand
  let ⟨h⟩ ← assertEq ValueKind.constantInt op.valueKind
  let op := ConstantIntRef.cast op h.symm
  assertBEq 1 (← op.getNatValue)
  let op ← inst.getPointerOperand
  assertBEq ValueKind.constantPointerNull op.valueKind
  assertBEq false (← inst.getVolatile)
  assertBEq 1 (← inst.getAlign)
  assertBEq AtomicOrdering.notAtomic (← inst.getOrdering)
  assertBEq SyncScopeID.system (← inst.getSyncScopeID)

-- simple GEP
#eval LlvmM.run do
  let i8Ty ← int8Type.getRef
  let i8pTy ← int8Type.pointerType.getRef
  let nullptr ← i8pTy.getNullConstant
  let idxTy ← int64Type.getRef
  let idx1 ← idxTy.getConstantNat 1
  let inst ← GetElementPtrInstRef.create i8Ty nullptr #[idx1]
  assertBEq ValueKind.instruction inst.valueKind
  assertBEq InstructionKind.getElementPtr inst.instructionKind
  assertBEq false (← inst.getInbounds)
  inst.setInbounds
  assertBEq true (← inst.getInbounds)
  let op ← inst.getPointerOperand
  assertBEq ValueKind.constantPointerNull op.valueKind
  let indices ← inst.getIndices
  if h : 0 < indices.size then
    let idx ← indices.get ⟨0, h⟩
    let ⟨h⟩ ← assertEq ValueKind.constantInt idx.valueKind
    let idx := ConstantIntRef.cast idx h.symm
    assertBEq 1 (← idx.getNatValue)
  else
    throw <| IO.userError "unexpected empty array"

-- simple `call`
#eval LlvmM.run do
  let fnTy ← functionType voidType #[] |>.getRef
  let fn ← FunctionRef.create fnTy
  let inst ← CallInstRef.create fnTy fn #[]
  assertBEq ValueKind.instruction inst.valueKind
  assertBEq InstructionKind.call inst.instructionKind
