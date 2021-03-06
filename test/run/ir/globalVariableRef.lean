import Papyrus

open Papyrus

def assertEq [Repr α] [DecidableEq α]
(expected actual : α) : IO (PLift (expected = actual)) := do
  if h : expected = actual then return PLift.up h else
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
  unless expected == actual do
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

-- global string constant
#eval LlvmM.run do
  let str := "foo"
  let name := "myConst"
  let gbl ← GlobalVariableRef.ofString str (withNull := false) (name := name)
  assertBEq name (← gbl.getName)
  assertBEq ValueKind.globalVariable gbl.valueKind
  assertBEq Linkage.private (← gbl.getLinkage)
  assertBEq Visibility.default (← gbl.getVisibility)
  assertBEq DLLStorageClass.default (← gbl.getDLLStorageClass)
  assertBEq ThreadLocalMode.notLocal (← gbl.getThreadLocalMode)
  assertBEq AddressSignificance.none (← gbl.getAddressSignificance)
  assertBEq AddressSpace.default (← gbl.getAddressSpace)
  assertBEq true (← gbl.hasInitializer)
  let init  ← gbl.getInitializer
  let ⟨h⟩ ← assertEq ValueKind.constantDataArray init.valueKind
  let init := ConstantDataArrayRef.cast init h.symm
  assertBEq true (← init.isString)
  assertBEq str (← init.getAsString)
  assertBEq 1 (← gbl.getRawAlignment)
  assertBEq false (← gbl.hasSection)
