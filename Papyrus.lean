import Papyrus.IR.Types
import Papyrus.IR.Constants
import Papyrus.IR.Instructions
import Papyrus.IR.BasicBlock
import Papyrus.IR.Function
import Papyrus.IR.Module

open Papyrus

--------------------------------------------------------------------------------
-- General Test Helpers
--------------------------------------------------------------------------------

def assertFail (msg : String) : IO PUnit:= do
  IO.eprintln msg

def assertEq [Repr α] [DecidableEq α] (expected : α) (actual : α) : IO PUnit := do
  unless expected = actual do
    assertFail s!"expected '{repr expected}', got '{repr actual}'"

def assertBEq [Repr α] [BEq α] (expected : α) (actual : α) : IO PUnit := do
  unless expected == actual do
    assertFail s!"expected '{repr expected}', got '{repr actual}'"

def testcase (name : String) [Monad m] [MonadLiftT IO m] (action : m PUnit) : m PUnit := do
  IO.println s!"Running test '{name}' ..."
  action

--------------------------------------------------------------------------------
-- Type Tests
--------------------------------------------------------------------------------

def printRefTypeID (ref : TypeRef) : IO PUnit := do
  IO.println <| repr (← ref.getTypeID)

def assertRefTypeID (expectedID : TypeID) (ref : TypeRef) : IO PUnit := do
  assertBEq expectedID (← ref.getTypeID)

def assertIntTypeRoundtrips (type : IntegerType n) : LLVM PUnit := do
  let ref ← type.getRef
  assertBEq TypeID.integer (← ref.getTypeID)
  assertBEq n (← ref.getBitWidth).toNat

def assertFunTypeRoundtrips
[ToTypeRef r] [ToTypeRefArray p] (type : FunctionType r p a)
: LLVM PUnit := do
  let ref ← type.getRef
  assertBEq TypeID.function (← ref.getTypeID)
  assertBEq (← (← toTypeRef type.resultType).getTypeID) (← (← ref.getReturnType).getTypeID)
  assertBEq (← toTypeRefArray type.parameterTypes).size (← ref.getParameterTypes).size
  assertBEq type.isVarArg (← ref.isVarArg)

def assertVectorTypeRoundtrips [ToTypeRef e] (type : VectorType e n s) : LLVM PUnit := do
  let ref ← type.getRef
  assertBEq (ite type.isScalable TypeID.scalableVector TypeID.fixedVector) (← ref.getTypeID)
  assertBEq (← (← toTypeRef type.elementType).getTypeID) (← (← ref.getElementType).getTypeID)
  assertBEq type.minSize (← ref.getMinSize)
  assertBEq type.isScalable (← ref.isScalable)

def testTypes : LLVM PUnit := do

  testcase "special types" do
    assertRefTypeID TypeID.void       (← voidType.getRef)
    assertRefTypeID TypeID.label      (← labelType.getRef)
    assertRefTypeID TypeID.metadata   (← metadataType.getRef)
    assertRefTypeID TypeID.token      (← tokenType.getRef)
    assertRefTypeID TypeID.x86MMX     (← x86MMXType.getRef)
    assertRefTypeID TypeID.x86AMX     (← x86AMXType.getRef)

  testcase "floating point types" do
    assertRefTypeID TypeID.half       (← halfType.getRef)
    assertRefTypeID TypeID.bfloat     (← bfloatType.getRef)
    assertRefTypeID TypeID.float      (← floatType.getRef)
    assertRefTypeID TypeID.double     (← doubleType.getRef)
    assertRefTypeID TypeID.x86FP80    (← x86FP80Type.getRef)
    assertRefTypeID TypeID.fp128      (← fp128Type.getRef)
    assertRefTypeID TypeID.ppcFP128   (← ppcFP128Type.getRef)

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
    assertRefTypeID TypeID.pointer ref
    assertRefTypeID TypeID.double (← ref.getPointeeType)
    assertBEq AddressSpace.default (← ref.getAddressSpace)

  testcase "literal struct types" do
    let ref ← literalStructType (halfType, doubleType) |>.getRef
    assertRefTypeID TypeID.struct ref
    assertBEq 2 (← ref.getElementTypes).size
    assertBEq false (← ref.isPacked)

  testcase "complete struct types" do
    let name := "foo"
    let ref ← completeStructType name halfType true |>.getRef
    assertRefTypeID TypeID.struct ref
    assertBEq name (← ref.getName)
    assertBEq 1 (← ref.getElementTypes).size
    assertBEq true (← ref.isPacked)

  testcase "opaque struct types" do
    let name := "bar"
    let ref ← opaqueStructType name |>.getRef
    assertRefTypeID TypeID.struct ref
    assertBEq name (← ref.getName)

  testcase "array types" do
    let size := 8
    let ref ← arrayType halfType size |>.getRef
    assertRefTypeID TypeID.array ref
    assertRefTypeID TypeID.half (← ref.getElementType)
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
-- Instruction Tests
--------------------------------------------------------------------------------

def testInstructions : LLVM PUnit := do

  testcase "empty return instruction" do
    let inst ← ReturnInstRef.create none
    unless (← inst.getReturnValue).isNone do
      assertFail "got return value when expecting none"

  testcase "nonempty return instruction" do
    let val := 1
    let const ← (← int32Type.getRef).getConstantInt val
    let inst ← ReturnInstRef.create <| some const
    let some retVal ← inst.getReturnValue
      | assertFail "got unexpected empty return value"
    let retInt : ConstantIntRef := retVal
    assertBEq val (← retInt.getValue)

--------------------------------------------------------------------------------
-- Basic Block Test
--------------------------------------------------------------------------------

def testBasicBlock : LLVM PUnit := do

  testcase "basic block" do
    let name := "foo"
    let bb ← BasicBlockRef.create name
    assertBEq name (← bb.getName)
    let inst ← ReturnInstRef.create <| none
    bb.appendInstruction inst
    let is ← bb.getInstructions
    if h : is.size = 1 then
      let inst : ReturnInstRef ← is.get (Fin.mk 0 (by simp [h]))
      unless (← inst.getReturnValue).isNone do
        assertFail "got return value when expecting none"
    else
      assertFail s!"expected 1 instruction in basic block, got {is.size}"

--------------------------------------------------------------------------------
-- Function Test
--------------------------------------------------------------------------------

def testFunction : LLVM PUnit := do

  testcase "empty function" do
    let name := "foo"
    let fnTy ← functionType voidType int64Type |>.getRef
    let fn ← FunctionRef.create fnTy name
    assertBEq name (← fn.getName)
    assertBEq Linkage.external (← fn.getLinkage)
    assertBEq Visibility.default (← fn.getVisibility)
    assertBEq DLLStorageClass.default (← fn.getDLLStorageClass)
    assertBEq AddressSignificance.global (← fn.getAddressSignificance)
    assertBEq AddressSpace.default (← fn.getAddressSpace)

  testcase "single block function" do
    let bbName := "foo"
    let fnTy ← functionType voidType () |>.getRef
    let fn ← FunctionRef.create fnTy "test"
    let bb ← BasicBlockRef.create bbName
    fn.appendBasicBlock bb
    let bbs ← fn.getBasicBlocks
    if h : bbs.size = 1 then
      let bb : FunctionRef ← bbs.get (Fin.mk 0 (by simp [h]))
      assertBEq bbName (← bb.getName)
    else
      assertFail s!"expected 1 basic block in function, got {bbs.size}"

--------------------------------------------------------------------------------
-- Module Tests
--------------------------------------------------------------------------------

def testModule : LLVM PUnit := do

  testcase "module renaming" do
    let name1 := "foo"
    let mod ← ModuleRef.new name1
    assertBEq name1 (← mod.getModuleID)
    let name2 := "bar"
    mod.setModuleID name2
    assertBEq name2 (← mod.getModuleID)

  testcase "single function module" do
    let fnName := "foo"
    let mod ← ModuleRef.new "test"
    let fnTy ← functionType voidType () |>.getRef
    let fn ← FunctionRef.create fnTy fnName
    mod.appendFunction fn
    let fns ← mod.getFunctions
    if h : fns.size = 1 then
      let fn : FunctionRef ← fns.get (Fin.mk 0 (by simp [h]))
      assertBEq fnName (← fn.getName)
    else
      assertFail s!"expected 1 function in module, got {fns.size}"

  testcase "test write module bitcode" do

    -- Construct Module
    let exitCode := 101
    let mod ← ModuleRef.new "test"
    let fnTy ← functionType int32Type () |>.getRef
    let fn ← FunctionRef.create fnTy "main"
    let bb ← BasicBlockRef.create "entry"
    let const ← (← int32Type.getRef).getConstantInt exitCode
    let inst ← ReturnInstRef.create <| some const
    bb.appendInstruction inst
    fn.appendBasicBlock bb
    mod.appendFunction fn

    -- Output It
    let outDir : System.FilePath := "out"
    IO.FS.createDirAll outDir
    mod.writeBitcodeToFile <| outDir / "exit.bc"
--------------------------------------------------------------------------------
-- Test Runner
--------------------------------------------------------------------------------

def main : IO PUnit := LLVM.run do

  testTypes
  testConstants
  testInstructions
  testBasicBlock
  testFunction
  testModule

  IO.println "All tests finished."
