import Papyrus

open Papyrus

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
  unless expected == actual do
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

-- ret void test
#eval show IO PUnit from LlvmM.run do
  let inst ← ReturnInstRef.createVoid
  unless (← inst.getReturnValue).isNone do
    throw <| IO.userError "got return value when expecting none"

-- non-void ret test
#eval show IO PUnit from LlvmM.run do
  let val := 1
  let intTypeRef ← IntegerTypeRef.get 32
  let const ← intTypeRef.getConstantInt val
  let inst ← ReturnInstRef.create const
  let some retVal ← inst.getReturnValue
    |  throw <| IO.userError "got unexpected void return"
  let retInt ← ConstantIntRef.getIntValue retVal
  assertBEq val retInt
