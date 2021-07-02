import Papyrus.Init
import Papyrus.Context
import Papyrus.IR.TypeRefs
import Papyrus.IR.ConstantRefs
import Papyrus.IR.InstructionRefs
import Papyrus.IR.BasicBlockRef
import Papyrus.IR.FunctionRef
import Papyrus.IR.ModuleRef
import Papyrus.ExecutionEngineRef

open Papyrus

--------------------------------------------------------------------------------
-- Assertions
--------------------------------------------------------------------------------

structure AssertionError where
  message : String

instance : ToString AssertionError := ⟨AssertionError.message⟩

abbrev AssertT  := ExceptT AssertionError

section
variable {m} [Monad m]

def assertFail (message : String) : AssertT m PUnit :=
  throwThe AssertionError ⟨message⟩

def assertTrue (actual : Bool) : AssertT m PUnit  :=
  unless actual do
    assertFail "expected true, got false"

def assertFalse (actual : Bool) : AssertT m PUnit := do
  if actual then
    assertFail "expected false, got true"

def assertEq [Repr α] [DecidableEq α] (expected actual : α) : AssertT m PUnit := do
  unless expected = actual do
    assertFail s!"expected '{repr expected}', got '{repr actual}'"

def assertBEq [Repr α] [BEq α] (expected actual : α) : AssertT m PUnit := do
  unless expected == actual do
    assertFail s!"expected '{repr expected}', got '{repr actual}'"

end

--------------------------------------------------------------------------------
-- Test Suites
--------------------------------------------------------------------------------

structure Test (m) where
  name : String
  run : AssertT m PUnit

structure Suite (m) where
  tests       : Array (Test m)
  beforeAll   : m PUnit
  beforeEach  : m PUnit
  afterEach   : m PUnit
  afterAll    : m PUnit

def Suite.empty [Pure m] : Suite m := {
  tests       := #[]
  beforeAll   := pure ()
  beforeEach  := pure ()
  afterEach   := pure ()
  afterAll    := pure ()
}

instance [Pure m] : Inhabited (Suite m) := ⟨Suite.empty⟩

def Suite.appendTest (test : Test m) (self : Suite m) : Suite m :=
  {self with tests := self.tests.push test}

def Suite.appendBeforeAll [SeqRight m] (action : m PUnit) (self : Suite m) : Suite m :=
  {self with beforeAll := self.beforeAll *> action}

def Suite.appendBeforeEach [SeqRight m] (action : m PUnit) (self : Suite m) : Suite m :=
  {self with beforeEach := self.beforeEach *> action}

def Suite.appendAfterEach [SeqRight m] (action : m PUnit) (self : Suite m) : Suite m :=
 {self with afterEach := self.afterEach *> action}

def Suite.appendAfterAll [SeqRight m] (action : m PUnit) (self : Suite m) : Suite m :=
 {self with afterAll := self.afterAll *> action}

/--
  Run the tests in this suite,
  returning an array of failing tests and their errors in the suite monad.
-/
def Suite.run [Monad m] (self : Suite m) : m (Array (Test m × AssertionError)) := do
  let mut failures := #[]
  self.beforeAll
  for test in self.tests do
    self.beforeEach
    match (← test.run) with
    | Except.ok _ => pure ()
    | Except.error e =>
      failures := failures.push (test, e)
    self.afterEach
  self.afterAll
  return failures

/-- Run the tests in this suite, printing out results along the way. -/
def Suite.runIO
[Monad m] [MonadLiftT IO m] [MonadExceptOf IO.Error m] (self : Suite m)
: m PUnit := do
  let mut passCount := 0
  let mut failCount := 0
  try self.beforeAll catch e =>
    IO.eprintln s!"unexpected exception in before all callback: {e}"
  for test in self.tests do
    IO.println s!"Running {test.name} ..."
    try self.beforeEach catch e =>
      IO.eprintln s!"unexpected exception in before each callback: {e}"
    try
      match (← test.run) with
      | Except.ok _ =>
        passCount := passCount + 1
      | Except.error e =>
        IO.eprintln e.message
        failCount := failCount + 1
    catch e : IO.Error =>
      IO.eprintln s!"unexpected exception in test: {e}"
    try self.afterEach catch e =>
      IO.eprintln s!"unexpected exception in after each callback: {e}"
  try self.afterAll catch e =>
    IO.eprintln s!"unexpected exception in before all callback: {e}"
  IO.println s!"Tests finished. {passCount} passed. {failCount} failed."

-- # Suite Monad

abbrev SuiteT (m) := StateM (Suite m)

def SuiteT.runIO
[Monad m] [MonadLiftT IO m] [MonadExceptOf IO.Error m] (self : SuiteT m PUnit)
: m PUnit := do
  StateT.run self Suite.empty |>.run.2.runIO

def beforeAll [SeqRight m] (action : m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendBeforeAll action

def beforeEach [SeqRight m] (action : m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendBeforeEach action

def test (name : String) (action : AssertT m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendTest ⟨name, action⟩

def afterEach [SeqRight m] (action : m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendAfterAll action

def afterAll [SeqRight m] (action : m PUnit) : SuiteT m PUnit :=
  modify fun suite => suite.appendAfterAll action

--------------------------------------------------------------------------------
-- Type Tests
--------------------------------------------------------------------------------

def assertBEqRefArray  {m} [Monad m] [MonadLiftT IO m]
  (expected actual : Array TypeRef) : AssertT m PUnit := do
  assertBEq expected.size actual.size
  for (expectedElem, actualElem) in Array.zip expected actual do
    assertBEq (← expectedElem.getTypeID) (← actualElem.getTypeID)

def assertFunTypeRoundtrips
(retType : TypeRef) (paramTypes : Array TypeRef) (isVarArg : Bool)
: AssertT LLVM PUnit := do
  let ref ← FunctionTypeRef.get retType paramTypes isVarArg
  assertBEq TypeID.function (← ref.getTypeID)
  assertBEq (← retType.getTypeID) (← (← ref.getReturnType).getTypeID)
  assertBEqRefArray paramTypes (← ref.getParameterTypes)
  assertBEq isVarArg (← ref.isVarArg)

def assertVectorTypeRoundtrips
(elementType : TypeRef) (minSize : UInt32) (isScalable : Bool)
: AssertT LLVM PUnit := do
  let ref ← VectorTypeRef.get elementType minSize isScalable
  let expectedId := if isScalable then TypeID.scalableVector else TypeID.fixedVector
  assertBEq expectedId (← ref.getTypeID)
  assertBEq (← elementType.getTypeID) (← (← ref.getElementType).getTypeID)
  assertBEq minSize (← ref.getMinSize)
  assertBEq isScalable (← ref.isScalable)

def testTypes : SuiteT LLVM PUnit := do

  test "special types" do
    assertBEq TypeID.void       (← (← getVoidTypeRef).getTypeID)
    assertBEq TypeID.label      (← (← getLabelTypeRef).getTypeID)
    assertBEq TypeID.metadata   (← (← getMetadataTypeRef).getTypeID)
    assertBEq TypeID.token      (← (← getTokenTypeRef).getTypeID)
    assertBEq TypeID.x86MMX     (← (← getX86MMXTypeRef).getTypeID)
    assertBEq TypeID.x86AMX     (← (← getX86AMXTypeRef).getTypeID)

  test "floating point types" do
    assertBEq TypeID.half       (← (← getHalfTypeRef).getTypeID)
    assertBEq TypeID.bfloat     (← (← getBFloatTypeRef).getTypeID)
    assertBEq TypeID.float      (← (← getFloatTypeRef).getTypeID)
    assertBEq TypeID.double     (← (← getDoubleTypeRef).getTypeID)
    assertBEq TypeID.x86FP80    (← (← getX86FP80TypeRef).getTypeID)
    assertBEq TypeID.fp128      (← (← getFP128TypeRef).getTypeID)
    assertBEq TypeID.ppcFP128   (← (← getPPCFP128TypeRef).getTypeID)

  test "integer types" do
    let n := 100
    let ref ← IntegerTypeRef.get n
    assertBEq TypeID.integer (← ref.getTypeID)
    assertBEq n (← ref.getBitWidth)

  test "function types" do
    let retType ← getVoidTypeRef
    let paramAType ← getDoubleTypeRef
    let paramBType ← IntegerTypeRef.get 100
    assertFunTypeRoundtrips retType #[paramAType] false
    assertFunTypeRoundtrips retType #[paramBType, paramAType] true

  test "pointer types" do
    let pointeeType ← getDoubleTypeRef
    let ref ← PointerTypeRef.get pointeeType
    assertBEq TypeID.pointer (← ref.getTypeID)
    assertBEq (← pointeeType.getTypeID) (← (← ref.getPointeeType).getTypeID)
    assertBEq AddressSpace.default (← ref.getAddressSpace)

  test "literal struct types" do
    let elemTypes := #[← getHalfTypeRef, ← getDoubleTypeRef]
    let ref ← LiteralStructTypeRef.get elemTypes
    assertBEq TypeID.struct (← ref.getTypeID)
    assertBEq true (← ref.isLiteral)
    assertBEq false (← ref.isOpaque)
    assertBEqRefArray elemTypes (← ref.getElementTypes)
    assertBEq false (← ref.isPacked)

  test "complete struct types" do
    let name := "foo"
    let elemTypes := #[← getFloatTypeRef]
    let ref ← IdentifiedStructTypeRef.create name elemTypes true
    assertBEq TypeID.struct (← ref.getTypeID)
    assertBEq name (← ref.getName)
    assertBEq false (← ref.isLiteral)
    assertBEq false (← ref.isOpaque)
    assertBEqRefArray elemTypes (← ref.getElementTypes)
    assertBEq true (← ref.isPacked)

  test "opaque struct types" do
    let name := "bar"
    let ref ← IdentifiedStructTypeRef.createOpaque name
    assertBEq TypeID.struct (← ref.getTypeID)
    assertBEq name (← ref.getName)
    assertBEq false (← ref.isLiteral)
    assertBEq true (← ref.isOpaque)
    assertBEq 0 (← ref.getElementTypes).size
    assertBEq false (← ref.isPacked)

  test "array types" do
    let size := 8
    let elemType ← IntegerTypeRef.get 30
    let ref ← ArrayTypeRef.get elemType size
    assertBEq TypeID.array (← ref.getTypeID)
    assertBEq (← elemType.getTypeID) (← (← ref.getElementType).getTypeID)
    assertBEq size (← ref.getSize)

  test "vector types" do
    let elemType ← getDoubleTypeRef
    assertVectorTypeRoundtrips elemType 8 false
    assertVectorTypeRoundtrips elemType 16 true

--------------------------------------------------------------------------------
-- Constant Tests
--------------------------------------------------------------------------------

def testConstants : SuiteT LLVM PUnit := do

  test "big null integer constant" do
    let int128TypeRef ← IntegerTypeRef.get 128
    let const : ConstantIntRef ← int128TypeRef.getNullConstant
    assertBEq 0 (← const.getNatValue)
    assertBEq 0 (← const.getValue)

  test "big all ones integer constant" do
    let int128TypeRef ← IntegerTypeRef.get 128
    let const : ConstantIntRef ← int128TypeRef.getAllOnesConstant
    assertBEq (2 ^ 128 - 1) (← const.getNatValue)
    assertBEq (-1) (← const.getValue)

  test "small positive constructed integer constant" do
    let val := 32
    let int8TypeRef ← IntegerTypeRef.get 8
    let const ← int8TypeRef.getConstantInt val
    assertBEq val (← const.getNatValue)
    assertBEq val (← const.getValue)

  test "small negative constructed integer constant" do
    let absVal := 32; let intVal := -32
    let int8TypeRef ← IntegerTypeRef.get 8
    let const ← int8TypeRef.getConstantInt intVal
    assertBEq (2 ^ 8 - absVal) (← const.getNatValue)
    assertBEq intVal (← const.getValue)

  test "big positive constructed integer constant" do
    let val : Nat := 2 ^ 80 + 12
    let int128TypeRef ← IntegerTypeRef.get 128
    let const ← int128TypeRef.getConstantInt val
    assertBEq (Int.ofNat val) (← const.getValue)
    assertBEq val (← const.getNatValue)

  test "big negative constructed integer constant" do
    let absVal := 2 ^ 80 + 12
    let intVal := -(Int.ofNat absVal)
    let int128TypeRef ← IntegerTypeRef.get 128
    let const ← int128TypeRef.getConstantInt intVal
    assertBEq (Int.ofNat (2 ^ 128) - absVal) (← const.getNatValue)
    assertBEq intVal (← const.getValue)

--------------------------------------------------------------------------------
-- Instruction Tests
--------------------------------------------------------------------------------

def testInstructions : SuiteT LLVM PUnit := do

  test "empty return instruction" do
    let inst ← ReturnInstRef.createEmpty
    unless (← inst.getReturnValue).isNone do
      assertFail "got return value when expecting none"

  test "nonempty return instruction" do
    let val := 1
    let intTypeRef ← IntegerTypeRef.get 32
    let const ← intTypeRef.getConstantInt val
    let inst ← ReturnInstRef.create const
    let some retVal ← inst.getReturnValue
      | assertFail "got unexpected empty return value"
    let retInt : ConstantIntRef := retVal
    assertBEq val (← retInt.getValue)

--------------------------------------------------------------------------------
-- Basic Block Test
--------------------------------------------------------------------------------

def testBasicBlock : SuiteT LLVM PUnit := do

  test "basic block" do
    let name := "foo"
    let bb ← BasicBlockRef.create name
    assertBEq name (← bb.getName)
    let inst ← ReturnInstRef.createEmpty
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

def testFunction : SuiteT LLVM PUnit := do

  test "empty function" do
    let name := "foo"
    let voidTypeRef ← getVoidTypeRef
    let fnTy ← FunctionTypeRef.get voidTypeRef #[]
    let fn ← FunctionRef.create fnTy name
    assertBEq name (← fn.getName)
    assertBEq Linkage.external (← fn.getLinkage)
    assertBEq Visibility.default (← fn.getVisibility)
    assertBEq DLLStorageClass.default (← fn.getDLLStorageClass)
    assertBEq AddressSignificance.global (← fn.getAddressSignificance)
    assertBEq AddressSpace.default (← fn.getAddressSpace)

  test "single block function" do
    let bbName := "foo"
    let voidTypeRef ← getVoidTypeRef
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

def testModule : SuiteT LLVM PUnit := do

  test "module renaming" do
    let name1 := "foo"
    let mod ← ModuleRef.new name1
    assertBEq name1 (← mod.getModuleID)
    let name2 := "bar"
    mod.setModuleID name2
    assertBEq name2 (← mod.getModuleID)

  test "single function module" do
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
      assertFail s!"expected 1 function in module, got {fns.size}"

  test "simple module" do
    -- Construct Module
    let exitCode := 101
    let mod ← ModuleRef.new "foo"
    let intTypeRef ← IntegerTypeRef.get 32
    let fnTy ← FunctionTypeRef.get intTypeRef #[]
    let fn ← FunctionRef.create fnTy "main"
    let bb ← BasicBlockRef.create
    let const ← intTypeRef.getConstantInt exitCode
    let inst ← ReturnInstRef.create const
    bb.appendInstruction inst
    fn.appendBasicBlock bb
    mod.appendFunction fn
    -- Verify It
    assertFalse (← mod.verify)
    -- Run It
    assertFalse (← initNativeTarget)
    assertFalse (← initNativeAsmPrinter)
    let ee ← ExecutionEngineRef.createForModule mod
    let ret ← ee.runFunction fn #[]
    assertBEq 101 (← ret.toInt)
    -- Output It
    let outDir : System.FilePath := "out"
    IO.FS.createDirAll outDir
    mod.writeBitcodeToFile <| outDir / "exit.bc"

--------------------------------------------------------------------------------
-- Test Runner
--------------------------------------------------------------------------------

def main : IO PUnit :=
  LLVM.run <| SuiteT.runIO do
    testTypes
    testConstants
    testInstructions
    testBasicBlock
    testFunction
    testModule
