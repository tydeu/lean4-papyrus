import Papyrus.IR.TypeRefs
import Papyrus.IR.Constants
import Papyrus.IR.Instructions
import Papyrus.IR.BasicBlock
import Papyrus.IR.Function
import Papyrus.IR.Module

open Papyrus

--------------------------------------------------------------------------------
-- General Test Helpers
--------------------------------------------------------------------------------

def assertFail (msg : String) : IO PUnit := do
  IO.eprintln msg

def assertTrue (actual : Bool) : IO PUnit :=
  unless actual do
    assertFail "expected true, got false"

def assertFalse (actual : Bool) : IO PUnit := do
  if actual then
    assertFail "expected false, got got"

def assertEq [Repr α] [DecidableEq α] (expected actual : α) : IO PUnit := do
  unless expected = actual do
    assertFail s!"expected '{repr expected}', got '{repr actual}'"

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
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

def assertBEqRefArray (expected actual : Array TypeRef) : IO PUnit := do
  assertBEq expected.size actual.size
  for (expectedElem, actualElem) in Array.zip expected actual do
    assertBEq (← expectedElem.getTypeID) (← actualElem.getTypeID)

def assertFunTypeRoundtrips
(retType : TypeRef) (paramTypes : Array TypeRef) (isVarArg : Bool)
: LLVM PUnit := do
  let ref ← FunctionTypeRef.get retType paramTypes isVarArg
  assertBEq TypeID.function (← ref.getTypeID)
  assertBEq (← retType.getTypeID) (← (← ref.getReturnType).getTypeID)
  assertBEqRefArray paramTypes (← ref.getParameterTypes)
  assertBEq isVarArg (← ref.isVarArg)

def assertVectorTypeRoundtrips
(elementType : TypeRef) (minSize : UInt32) (isScalable : Bool)
: LLVM PUnit := do
  let ref ← VectorTypeRef.get elementType minSize isScalable
  let expectedId := if isScalable then TypeID.scalableVector else TypeID.fixedVector
  assertBEq expectedId (← ref.getTypeID)
  assertBEq (← elementType.getTypeID) (← (← ref.getElementType).getTypeID)
  assertBEq minSize (← ref.getMinSize)
  assertBEq isScalable (← ref.isScalable)

def testTypes : LLVM PUnit := do

  testcase "special types" do
    assertBEq TypeID.void       (← (← getVoidTypeRef).getTypeID)
    assertBEq TypeID.label      (← (← getLabelTypeRef).getTypeID)
    assertBEq TypeID.metadata   (← (← getMetadataTypeRef).getTypeID)
    assertBEq TypeID.token      (← (← getTokenTypeRef).getTypeID)
    assertBEq TypeID.x86MMX     (← (← getX86MMXTypeRef).getTypeID)
    assertBEq TypeID.x86AMX     (← (← getX86AMXTypeRef).getTypeID)

  testcase "floating point types" do
    assertBEq TypeID.half       (← (← getHalfTypeRef).getTypeID)
    assertBEq TypeID.bfloat     (← (← getBFloatTypeRef).getTypeID)
    assertBEq TypeID.float      (← (← getFloatTypeRef).getTypeID)
    assertBEq TypeID.double     (← (← getDoubleTypeRef).getTypeID)
    assertBEq TypeID.x86FP80    (← (← getX86FP80TypeRef).getTypeID)
    assertBEq TypeID.fp128      (← (← getFP128TypeRef).getTypeID)
    assertBEq TypeID.ppcFP128   (← (← getPPCFP128TypeRef).getTypeID)

  testcase "integer types" do
    let n := 100
    let ref ← IntegerTypeRef.get n
    assertBEq TypeID.integer (← ref.getTypeID)
    assertBEq n (← ref.getBitWidth)

  testcase "function types" do
    let retType ← getVoidTypeRef
    let paramAType ← getDoubleTypeRef
    let paramBType ← IntegerTypeRef.get 100
    assertFunTypeRoundtrips retType #[paramAType] false
    assertFunTypeRoundtrips retType #[paramBType, paramAType] true

  testcase "pointer types" do
    let pointeeType ← getDoubleTypeRef
    let ref ← PointerTypeRef.get pointeeType
    assertBEq TypeID.pointer (← ref.getTypeID)
    assertBEq (← pointeeType.getTypeID) (← (← ref.getPointeeType).getTypeID)
    assertBEq AddressSpace.default (← ref.getAddressSpace)

  testcase "literal struct types" do
    let elemTypes := #[← getHalfTypeRef, ← getDoubleTypeRef]
    let ref ← LiteralStructTypeRef.get elemTypes
    assertBEq TypeID.struct (← ref.getTypeID)
    assertBEq true (← ref.isLiteral)
    assertBEq false (← ref.isOpaque)
    assertBEqRefArray elemTypes (← ref.getElementTypes)
    assertBEq false (← ref.isPacked)

  testcase "complete struct types" do
    let name := "foo"
    let elemTypes := #[← getFloatTypeRef]
    let ref ← IdentifiedStructTypeRef.create name elemTypes true
    assertBEq TypeID.struct (← ref.getTypeID)
    assertBEq name (← ref.getName)
    assertBEq false (← ref.isLiteral)
    assertBEq false (← ref.isOpaque)
    assertBEqRefArray elemTypes (← ref.getElementTypes)
    assertBEq true (← ref.isPacked)

  testcase "opaque struct types" do
    let name := "bar"
    let ref ← IdentifiedStructTypeRef.createOpaque name
    assertBEq TypeID.struct (← ref.getTypeID)
    assertBEq name (← ref.getName)
    assertBEq false (← ref.isLiteral)
    assertBEq true (← ref.isOpaque)
    assertBEq 0 (← ref.getElementTypes).size
    assertBEq false (← ref.isPacked)

  testcase "array types" do
    let size := 8
    let elemType ← IntegerTypeRef.get 30
    let ref ← ArrayTypeRef.get elemType size
    assertBEq TypeID.array (← ref.getTypeID)
    assertBEq (← elemType.getTypeID) (← (← ref.getElementType).getTypeID)
    assertBEq size (← ref.getSize)

  testcase "vector types" do
    let elemType ← getDoubleTypeRef
    assertVectorTypeRoundtrips elemType 8 false
    assertVectorTypeRoundtrips elemType 16 true

--------------------------------------------------------------------------------
-- Constant Tests
--------------------------------------------------------------------------------

def testConstants : LLVM PUnit := do

  let int8TypeRef ← IntegerTypeRef.get 8
  let int128TypeRef ← IntegerTypeRef.get 128

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

  let intTypeRef ← IntegerTypeRef.get 32

  testcase "empty return instruction" do
    let inst ← ReturnInstRef.create none
    unless (← inst.getReturnValue).isNone do
      assertFail "got return value when expecting none"

  testcase "nonempty return instruction" do
    let val := 1
    let const ← intTypeRef.getConstantInt val
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

  let voidTypeRef ← getVoidTypeRef

  testcase "empty function" do
    let name := "foo"
    let fnTy ← FunctionTypeRef.get voidTypeRef #[]
    let fn ← FunctionRef.create fnTy name
    assertBEq name (← fn.getName)
    assertBEq Linkage.external (← fn.getLinkage)
    assertBEq Visibility.default (← fn.getVisibility)
    assertBEq DLLStorageClass.default (← fn.getDLLStorageClass)
    assertBEq AddressSignificance.global (← fn.getAddressSignificance)
    assertBEq AddressSpace.default (← fn.getAddressSpace)

  testcase "single block function" do
    let bbName := "foo"
    let fnTy ← FunctionTypeRef.get voidTypeRef #[]
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

  let voidTypeRef ← getVoidTypeRef
  let intTypeRef ← IntegerTypeRef.get 32

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
    let fnTy ← FunctionTypeRef.get voidTypeRef #[]
    let fn ← FunctionRef.create fnTy fnName
    mod.appendFunction fn
    let fns ← mod.getFunctions
    if h : fns.size = 1 then
      let fn : FunctionRef ← fns.get (Fin.mk 0 (by simp [h]))
      assertBEq fnName (← fn.getName)
    else
      assertFail s!"expected 1 function in module, got {fns.size}"

  testcase "simple module verify & write bitcode" do
    -- Construct Module
    let exitCode := 101
    let mod ← ModuleRef.new "test"
    let fnTy ← FunctionTypeRef.get intTypeRef #[]
    let fn ← FunctionRef.create fnTy "main"
    let bb ← BasicBlockRef.create "entry"
    let const ← intTypeRef.getConstantInt exitCode
    let inst ← ReturnInstRef.create <| some const
    bb.appendInstruction inst
    fn.appendBasicBlock bb
    mod.appendFunction fn
    -- Verify & Output It
    assertFalse (← mod.verify)
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
