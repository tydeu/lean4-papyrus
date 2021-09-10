
import Papyrus

open Papyrus

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
  unless expected == actual do
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

-- empty function
#eval LlvmM.run do
  let name := "foo"
  let voidTypeRef ← getVoidTypeRef
  let fnTy ← FunctionTypeRef.get voidTypeRef #[]
  let fn ← FunctionRef.create fnTy name
  assertBEq name (← fn.getName)
  assertBEq ValueKind.function fn.valueKind
  assertBEq Linkage.external (← fn.getLinkage)
  assertBEq Visibility.default (← fn.getVisibility)
  assertBEq DLLStorageClass.default (← fn.getDLLStorageClass)
  assertBEq ThreadLocalMode.notLocal (← fn.getThreadLocalMode)
  assertBEq AddressSignificance.total (← fn.getAddressSignificance)
  assertBEq AddressSpace.default (← fn.getAddressSpace)
  assertBEq CallingConvention.c (← fn.getCallingConvention)
  assertBEq 0 (← fn.getRawAlignment)
  assertBEq false (← fn.hasSection)
  assertBEq false (← fn.hasGC)

-- single block function
#eval LlvmM.run do
  let bbName := "foo"
  let voidTypeRef ← getVoidTypeRef
  let fnTy ← FunctionTypeRef.get voidTypeRef #[]
  let fn ← FunctionRef.create fnTy "test"
  let bb ← BasicBlockRef.create bbName
  fn.appendBasicBlock bb
  let bbs ← fn.getBasicBlocks
  if h : bbs.size = 1 then
    let bb ← bbs.get (Fin.mk 0 (by simp [h]))
    assertBEq bbName (← bb.getName)
  else
    throw <| IO.userError s!"expected 1 basic block in function, got {bbs.size}"
