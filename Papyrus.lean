import Papyrus.Types
import Papyrus.Module

open Papyrus

def printRefTypeID (ref : TypeRef) : LLVM PUnit := do
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
  assertRefTypeID TypeID.Void       (← voidType.getRef)
  assertRefTypeID TypeID.Label      (← labelType.getRef)
  assertRefTypeID TypeID.Metadata   (← metadataType.getRef)
  assertRefTypeID TypeID.Token      (← tokenType.getRef)
  assertRefTypeID TypeID.X86_MMX    (← x86MMXType.getRef)

  -- Test Floating Point Types
  assertRefTypeID TypeID.Half       (← halfType.getRef)
  assertRefTypeID TypeID.BFloat     (← bfloatType.getRef)
  assertRefTypeID TypeID.Float      (← floatType.getRef)
  assertRefTypeID TypeID.Double     (← doubleType.getRef)
  assertRefTypeID TypeID.X86_FP80   (← x86FP80Type.getRef)
  assertRefTypeID TypeID.FP128      (← fp128Type.getRef)
  assertRefTypeID TypeID.PPC_FP128  (← ppcFP128Type.getRef)

  -- Test Basic Derived Types
  assertRefTypeID TypeID.Integer    (← (integerType 32).getRef)
  assertRefTypeID TypeID.Pointer    (← doubleType.pointerType.getRef)
  assertRefTypeID TypeID.Array      (← (arrayType doubleType 8).getRef)

  -- Test Vector Types
  assertRefTypeID TypeID.FixedVector
    (← (fixedVectorType doubleType 8).getRef)
  assertRefTypeID TypeID.ScalableVector
    (← (scalableVectorType doubleType 8).getRef)

  IO.println "Finished."
