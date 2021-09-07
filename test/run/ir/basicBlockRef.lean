import Papyrus

open Papyrus

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
  unless expected == actual do
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

-- simple test
#eval LlvmM.run do
  let name := "foo"
  let bb ← BasicBlockRef.create name
  assertBEq ValueKind.basicBlock (← bb.getValueKind)
  let actualName ← bb.getName
  assertBEq name actualName
  let inst ← ReturnInstRef.createVoid
  bb.appendInstruction inst
  let is ← bb.getInstructions
  if h : is.size = 1 then
    let inst : ReturnInstRef ← is.get (Fin.mk 0 (by simp [h]))
    unless (← inst.getReturnValue).isNone do
      throw <| IO.userError "got return value when expecting none"
  else
    throw <| IO.userError s!"expected 1 instruction in basic block, got {is.size}"
