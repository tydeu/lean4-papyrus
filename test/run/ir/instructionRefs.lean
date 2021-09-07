import Papyrus

open Papyrus

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
  unless expected == actual do
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

-- ret void test
#eval LlvmM.run do
  let inst ← ReturnInstRef.createVoid
  assertBEq ValueKind.instruction (← inst.getValueKind)
  assertBEq InstructionKind.ret (← inst.getInstructionKind)
  unless (← inst.getReturnValue).isNone do
    throw <| IO.userError "got return value when expecting none"

-- non-void ret test
#eval LlvmM.run do
  let val := 1
  let intTypeRef ← IntegerTypeRef.get 32
  let const ← intTypeRef.getConstantInt val
  let inst ← ReturnInstRef.create const
  assertBEq ValueKind.instruction (← inst.getValueKind)
  assertBEq InstructionKind.ret (← inst.getInstructionKind)
  let some retVal ← inst.getReturnValue
    |  throw <| IO.userError "got unexpected void return"
  let retInt ← ConstantIntRef.getIntValue retVal
  assertBEq val retInt

-- simple GEP
#eval LlvmM.run do
  let i8Ty ← int8Type.getRef
  let i8pTy ← int8Type.pointerType.getRef
  let nullptr ← i8pTy.getNullConstant
  let idxTy ← int64Type.getRef
  let idx1 ← idxTy.getConstantNat 1
  let inst ← GetElementPtrInstRef.create i8Ty nullptr #[idx1]
  assertBEq ValueKind.instruction (← inst.getValueKind)
  assertBEq InstructionKind.getElementPtr (← inst.getInstructionKind)
  assertBEq false (← inst.getInbounds)
  inst.setInbounds
  assertBEq true (← inst.getInbounds)
  let op ← inst.getPointerOperand
  assertBEq ValueKind.constantPointerNull (← op.getValueKind)
  let indices ← inst.getIndices
  if h : 0 < indices.size then
    let idx : ConstantIntRef ← indices.get ⟨0, h⟩
    assertBEq 1 (← idx.getNatValue)
  else
    throw <| IO.userError "unexpected empty array"

-- simple call
#eval LlvmM.run do
  let fnTy ← Type.getRef <| functionType voidType #[]
  let fn ← FunctionRef.create fnTy
  let inst ← CallInstRef.create fnTy fn #[]
  assertBEq ValueKind.instruction (← inst.getValueKind)
  assertBEq InstructionKind.call (← inst.getInstructionKind)
