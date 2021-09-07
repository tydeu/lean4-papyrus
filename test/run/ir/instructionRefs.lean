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

-- simple call
#eval LlvmM.run do
  let fnTy ← Type.getRef <| functionType voidType #[]
  let fn ← FunctionRef.create fnTy
  let inst ← CallInstRef.create fnTy fn #[]
  assertBEq ValueKind.instruction (← inst.getValueKind)
  assertBEq InstructionKind.call (← inst.getInstructionKind)
