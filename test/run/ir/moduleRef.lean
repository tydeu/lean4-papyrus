import Papyrus

open Papyrus

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
  unless expected == actual do
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

-- module renaming
#eval show IO PUnit from LlvmM.run do
  let name1 := "foo"
  let mod ← ModuleRef.new name1
  assertBEq name1 (← mod.getModuleID)
  let name2 := "bar"
  mod.setModuleID name2
  assertBEq name2 (← mod.getModuleID)

-- single function module
#eval show IO PUnit from LlvmM.run do
  let fnName := "foo"
  let mod ← ModuleRef.new "test"
  let voidTypeRef ← getVoidTypeRef
  let fnTy ← FunctionTypeRef.get voidTypeRef #[]
  let fn ← FunctionRef.create fnTy fnName
  mod.appendFunction fn
  let fns ← mod.getFunctions
  if h : fns.size = 1 then
    let fn : FunctionRef ← fns.get (Fin.mk 0 (by simp [h]))
    assertBEq fnName (← fn.getName)
  else
    throw <| IO.userError s!"expected 1 function in module, got {fns.size}"
