import Papyrus

open Papyrus

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
  unless expected == actual do
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

-- null ptr constant
#eval LlvmM.run do
  let const ← (← int8Type.pointerType.getRef).getNullConstant
  assertBEq ValueKind.constantPointerNull (← const.getValueKind)

-- null token constant
#eval LlvmM.run do
  let const ← (← tokenType.getRef).getNullConstant
  assertBEq ValueKind.constantTokenNone (← const.getValueKind)

-- big null constant
#eval LlvmM.run do
  let int128TypeRef ← IntegerTypeRef.get 128
  let const : ConstantIntRef ← int128TypeRef.getNullConstant
  assertBEq ValueKind.constantInt (← const.getValueKind)
  assertBEq 0 (← const.getNatValue)
  assertBEq 0 (← const.getIntValue)

-- big all ones constant
#eval LlvmM.run do
  let int128TypeRef ← IntegerTypeRef.get 128
  let const : ConstantIntRef ← int128TypeRef.getAllOnesConstant
  assertBEq (2 ^ 128 - 1) (← const.getNatValue)
  assertBEq (-1) (← const.getIntValue)

-- small positive integer constant
#eval LlvmM.run do
  let val := 32
  let int8TypeRef ← IntegerTypeRef.get 8
  let const ← int8TypeRef.getConstantInt val
  assertBEq val (← const.getNatValue)
  assertBEq val (← const.getIntValue)

-- small negative integer constant
#eval LlvmM.run do
  let absVal := 32; let intVal := -32
  let int8TypeRef ← IntegerTypeRef.get 8
  let const ← int8TypeRef.getConstantInt intVal
  assertBEq (2 ^ 8 - absVal) (← const.getNatValue)
  assertBEq intVal (← const.getIntValue)

-- big positive integer constant
#eval LlvmM.run do
  let val : Nat := 2 ^ 80 + 12
  let int128TypeRef ← IntegerTypeRef.get 128
  let const ← int128TypeRef.getConstantInt val
  assertBEq (Int.ofNat val) (← const.getIntValue)
  assertBEq val (← const.getNatValue)

-- big negative integer constant
#eval LlvmM.run do
  let absVal := 2 ^ 80 + 12
  let intVal := -(Int.ofNat absVal)
  let int128TypeRef ← IntegerTypeRef.get 128
  let const ← int128TypeRef.getConstantInt intVal
  assertBEq (Int.ofNat (2 ^ 128) - absVal) (← const.getNatValue)
  assertBEq intVal (← const.getIntValue)

-- `inttoptr`/`ptrtoint` constant
#eval LlvmM.run do
  let ity ← int64Type.getRef
  let pty ← PointerTypeRef.get ity
  let cst ← ConstantIntRef.ofUInt64 1
  let itp ← ConstantExprRef.getIntToPtr cst pty
  let pti ← ConstantExprRef.getPtrToInt itp ity
  assertBEq TypeID.pointer (← (← itp.getType).getTypeID)
  assertBEq TypeID.integer (← (← pti.getType).getTypeID)
