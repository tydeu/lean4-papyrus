import Papyrus.Types
import Papyrus.Values
import Papyrus.Module

open Papyrus

--------------------------------------------------------------------------------
-- General Test Helpers
--------------------------------------------------------------------------------

def assertEq [Repr α] [DecidableEq α] (expected : α) (actual : α) : IO PUnit := do
  unless expected = actual do
    IO.eprintln s!"expected '{repr expected}', got '{repr actual}'"

def assertBEq [Repr α] [BEq α] (expected : α) (actual : α) : IO PUnit := do
  unless expected == actual do
    IO.eprintln s!"expected '{repr expected}', got '{repr actual}'"

def testcase (name : String) [Monad m] [MonadLiftT IO m] (action : m PUnit) : m PUnit := do
  IO.println s!"Running test '{name}' ..."
  action

--------------------------------------------------------------------------------
-- Basic Module Test
--------------------------------------------------------------------------------

def testModule : LLVM PUnit := do

  testcase "omodule naming" do
    let mod ← ModuleRef.new "hello"
    assertBEq "hello" (← mod.getModuleID)
    mod.setModuleID "world"
    assertBEq "world" (← mod.getModuleID)

--------------------------------------------------------------------------------
-- Type Tests
--------------------------------------------------------------------------------

def printRefTypeID (ref : TypeRef) : LLVM PUnit := do
  IO.println <| repr (← ref.getTypeID)

def assertRefTypeID (expectedID : TypeID) (ref : TypeRef) : IO PUnit := do
  assertBEq expectedID (← ref.getTypeID)

def testTypes : LLVM PUnit := do

  testcase "special types" do
    assertRefTypeID TypeID.Void       (← voidType.getRef)
    assertRefTypeID TypeID.Label      (← labelType.getRef)
    assertRefTypeID TypeID.Metadata   (← metadataType.getRef)
    assertRefTypeID TypeID.Token      (← tokenType.getRef)
    assertRefTypeID TypeID.X86_MMX    (← x86MMXType.getRef)

  testcase "floating point types" do
    assertRefTypeID TypeID.Half       (← halfType.getRef)
    assertRefTypeID TypeID.BFloat     (← bfloatType.getRef)
    assertRefTypeID TypeID.Float      (← floatType.getRef)
    assertRefTypeID TypeID.Double     (← doubleType.getRef)
    assertRefTypeID TypeID.X86_FP80   (← x86FP80Type.getRef)
    assertRefTypeID TypeID.FP128      (← fp128Type.getRef)
    assertRefTypeID TypeID.PPC_FP128  (← ppcFP128Type.getRef)

  testcase "integer types" do
    assertRefTypeID TypeID.Integer    (← int1Type.getRef)
    assertRefTypeID TypeID.Integer    (← int8Type.getRef)
    assertRefTypeID TypeID.Integer    (← int16Type.getRef)
    assertRefTypeID TypeID.Integer    (← int32Type.getRef)
    assertRefTypeID TypeID.Integer    (← int64Type.getRef)
    assertRefTypeID TypeID.Integer    (← int128Type.getRef)
    assertRefTypeID TypeID.Integer    (← integerType 100 |>.getRef)

  testcase "integer types" do
    assertRefTypeID TypeID.Function
      (← functionType voidType doubleType |>.getRef)
    assertRefTypeID TypeID.Function
      (← functionType voidType (floatType, int1Type) true |>.getRef)

  testcase "struct types" do
    assertRefTypeID TypeID.Struct
      (← structType "foo" halfType true |>.getRef)
    assertRefTypeID TypeID.Struct
      (← opaqueStructType "bar" |>.getRef)
    assertRefTypeID TypeID.Struct
      (← literalStructType (halfType, doubleType) |>.getRef)

  testcase "vector types" do
    assertRefTypeID TypeID.FixedVector
      (← fixedVectorType doubleType 8 |>.getRef)
    assertRefTypeID TypeID.ScalableVector
      (← scalableVectorType doubleType 8 |>.getRef)

  testcase "other types" do
    assertRefTypeID TypeID.Pointer    (← doubleType.pointerType.getRef)
    assertRefTypeID TypeID.Array      (← arrayType int8Type 8 |>.getRef)

--------------------------------------------------------------------------------
-- Constant Tests
--------------------------------------------------------------------------------

def testConstants : LLVM PUnit := do

  let int8TypeRef ← int8Type.getRef
  let int128TypeRef ← int128Type.getRef

  testcase "big null integer constant" do
    let const : ConstantIntRef ← int128TypeRef.getNullConstant
    assertBEq 0 (← const.getNatValue)
    assertBEq 0 (← const.getValue)

  testcase "big all ones integer constant" do
    let const : ConstantIntRef ← int128TypeRef.getAllOnesConstant
    assertBEq (2 ^ 128 - 1) (← const.getNatValue)
    assertBEq (-1) (← const.getValue)

  testcase "small positive constructed integer constant" do
    let val := 32
    let const ← ConstantIntRef.get val int8TypeRef
    assertBEq val (← const.getNatValue)
    assertBEq val (← const.getValue)

  testcase "small negative constructed integer constant" do
    let absVal := 32
    let intVal := -(Int.ofNat 32)
    let const ← ConstantIntRef.get intVal int8TypeRef
    assertBEq (2 ^ 8 - absVal) (← const.getNatValue)
    assertBEq intVal (← const.getValue)

  testcase "big positive constructed integer constant" do
    let val : Nat := 2 ^ 80 + 12
    let const ← ConstantIntRef.get val int128TypeRef
    assertBEq (Int.ofNat val) (← const.getValue)
    assertBEq val (← const.getNatValue)

  testcase "big negative constructed integer constant" do
    let absVal := 2 ^ 80 + 12
    let intVal := -(Int.ofNat absVal)
    let const ← ConstantIntRef.get intVal int128TypeRef
    assertBEq (Int.ofNat (2 ^ 128) - absVal) (← const.getNatValue)
    assertBEq intVal (← const.getValue)

--------------------------------------------------------------------------------
-- Test Runner
--------------------------------------------------------------------------------

def main : IO PUnit := LLVM.run do

  testModule
  testTypes
  testConstants

  IO.println "All tests finished."
