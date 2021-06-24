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

  -- Test Integer Types
  assertRefTypeID TypeID.Integer    (← int1Type.getRef)
  assertRefTypeID TypeID.Integer    (← int8Type.getRef)
  assertRefTypeID TypeID.Integer    (← int16Type.getRef)
  assertRefTypeID TypeID.Integer    (← int32Type.getRef)
  assertRefTypeID TypeID.Integer    (← int64Type.getRef)
  assertRefTypeID TypeID.Integer    (← int128Type.getRef)
  assertRefTypeID TypeID.Integer    (← integerType 100 |>.getRef)

  -- Test Function Types
  assertRefTypeID TypeID.Function
    (← functionType voidType doubleType |>.getRef)
  assertRefTypeID TypeID.Function
    (← functionType voidType (floatType, int1Type) true |>.getRef)

  -- Test Struct Types
  assertRefTypeID TypeID.Struct
    (← structType "foo" halfType true |>.getRef)
  assertRefTypeID TypeID.Struct
    (← opaqueStructType "bar" |>.getRef)
  assertRefTypeID TypeID.Struct
    (← literalStructType (halfType, doubleType) |>.getRef)

  -- Test Vector Types
  assertRefTypeID TypeID.FixedVector
    (← fixedVectorType doubleType 8 |>.getRef)
  assertRefTypeID TypeID.ScalableVector
    (← scalableVectorType doubleType 8 |>.getRef)

  -- Test Other Derived Types
  assertRefTypeID TypeID.Pointer    (← doubleType.pointerType.getRef)
  assertRefTypeID TypeID.Array      (← arrayType int8Type 8 |>.getRef)

  IO.println "Finished."
