import Papyrus.IR.Types
import Papyrus.IR.Constants
import Papyrus.IR.Module

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

def printRefTypeID (ref : TypeRef) : IO PUnit := do
  IO.println <| repr (← ref.getTypeID)

def assertRefTypeID (expectedID : TypeID) (ref : TypeRef) : IO PUnit := do
  assertBEq expectedID (← ref.getTypeID)

def assertIntTypeRoundtrips (type : IntegerType n) : LLVM PUnit := do
  let ref ← type.getRef
  assertBEq TypeID.Integer (← ref.getTypeID)
  assertBEq n (← ref.getBitWidth).toNat

def assertFunTypeRoundtrips
[ToTypeRef r] [ToTypeRefArray p] (type : FunctionType r p a)
: LLVM PUnit := do
  let ref ← type.getRef
  assertBEq TypeID.Function (← ref.getTypeID)
  assertBEq (← (← toTypeRef type.resultType).getTypeID) (← (← ref.getReturnType).getTypeID)
  assertBEq (← toTypeRefArray type.parameterTypes).size (← ref.getParameterTypes).size
  assertBEq type.isVarArg (← ref.isVarArg)

def assertVectorTypeRoundtrips [ToTypeRef e] (type : VectorType e n s) : LLVM PUnit := do
  let ref ← type.getRef
  assertBEq (ite type.isScalable TypeID.ScalableVector TypeID.FixedVector) (← ref.getTypeID)
  assertBEq (← (← toTypeRef type.elementType).getTypeID) (← (← ref.getElementType).getTypeID)
  assertBEq type.minSize (← ref.getMinSize)
  assertBEq type.isScalable (← ref.isScalable)

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
    assertIntTypeRoundtrips int1Type
    assertIntTypeRoundtrips int8Type
    assertIntTypeRoundtrips int16Type
    assertIntTypeRoundtrips int32Type
    assertIntTypeRoundtrips int64Type
    assertIntTypeRoundtrips int128Type
    assertIntTypeRoundtrips <| integerType 100

  testcase "function types" do
    assertFunTypeRoundtrips <| functionType voidType doubleType
    assertFunTypeRoundtrips <| functionType voidType (floatType, int1Type) true

  testcase "pointer types" do
    let ref ← doubleType.pointerType.getRef
    assertRefTypeID TypeID.Pointer ref
    assertRefTypeID TypeID.Double (← ref.getPointeeType)
    assertBEq AddressSpace.default (← ref.getAddressSpace)

  testcase "literal struct types" do
    let ref ← literalStructType (halfType, doubleType) |>.getRef
    assertRefTypeID TypeID.Struct ref
    assertBEq 2 (← ref.getElementsTypes).size
    assertBEq false (← ref.isPacked)

  testcase "complete struct types" do
    let name := "foo"
    let ref ← completeStructType name halfType true |>.getRef
    assertRefTypeID TypeID.Struct ref
    assertBEq name (← ref.getName)
    assertBEq 1 (← ref.getElementsTypes).size
    assertBEq true (← ref.isPacked)

  testcase "opaque struct types" do
    let name := "bar"
    let ref ← opaqueStructType name |>.getRef
    assertRefTypeID TypeID.Struct ref
    assertBEq name (← ref.getName)

  testcase "array types" do
    let size := 8
    let ref ← arrayType halfType size |>.getRef
    assertRefTypeID TypeID.Array ref
    assertRefTypeID TypeID.Half (← ref.getElementType)
    assertBEq size (← ref.getSize)

  testcase "vector types" do
    assertVectorTypeRoundtrips <| fixedVectorType doubleType 8
    assertVectorTypeRoundtrips <| scalableVectorType floatType 8

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
    let const ← int8TypeRef.getConstantInt val
    assertBEq val (← const.getNatValue)
    assertBEq val (← const.getValue)

  testcase "small negative constructed integer constant" do
    let absVal := 32; let intVal := -32
    let const ← int8TypeRef.getConstantInt intVal
    assertBEq (2 ^ 8 - absVal) (← const.getNatValue)
    assertBEq intVal (← const.getValue)

  testcase "big positive constructed integer constant" do
    let val : Nat := 2 ^ 80 + 12
    let const ← int128TypeRef.getConstantInt val
    assertBEq (Int.ofNat val) (← const.getValue)
    assertBEq val (← const.getNatValue)

  testcase "big negative constructed integer constant" do
    let absVal := 2 ^ 80 + 12
    let intVal := -(Int.ofNat absVal)
    let const ← int128TypeRef.getConstantInt intVal
    assertBEq (Int.ofNat (2 ^ 128) - absVal) (← const.getNatValue)
    assertBEq intVal (← const.getValue)

--------------------------------------------------------------------------------
-- Test Runner
--------------------------------------------------------------------------------

def main : IO PUnit := LLVM.run do

  testTypes
  testConstants
  testModule

  IO.println "All tests finished."
