import Papyrus.Types
import Papyrus.Module

open Papyrus

def printLLVMRefTypeID (ref : TypeRef) : LLVM PUnit := do
  IO.println <| repr (← ref.getTypeID)

def assertBEq [Repr α] [BEq α] (expected : α) (actual : α) : IO PUnit := do
  unless expected == actual do
    IO.eprintln s!"expected '{repr expected}', got '{repr actual}'"

def assertRefTypeID (expectedID : TypeID) (ref : TypeRef) : IO PUnit := do
  assertBEq expectedID (← ref.getTypeID)

def main : IO Unit := LLVM.run do

  -- Test Module
  let mod ← ModuleRef.new "hello"
  assertBEq "hello" (← mod.getModuleID)
  mod.setModuleID "world"
  assertBEq "world" (← mod.getModuleID)

  -- Test Special Types
  assertRefTypeID TypeID.Void     (← voidType.getRef)
  assertRefTypeID TypeID.Label    (← labelType.getRef)
  assertRefTypeID TypeID.Metadata (← metadataType.getRef)
  assertRefTypeID TypeID.Token    (← tokenType.getRef)
  assertRefTypeID TypeID.X86_MMX  (← x86MMXType.getRef)

  -- Test Floating Point Types
  assertRefTypeID TypeID.Half     (← halfType.getRef)
  assertRefTypeID TypeID.Float    (← floatType.getRef)
  assertRefTypeID TypeID.Double   (← doubleType.getRef)

  -- Test Derived Types
  assertRefTypeID TypeID.Integer (← (integerType 32).getRef)
  assertRefTypeID TypeID.Pointer (← doubleType.pointer.getRef)

  IO.println "Finished."
