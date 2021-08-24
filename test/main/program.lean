import Papyrus
open Papyrus

--------------------------------------------------------------------------------
-- # Helpers
--------------------------------------------------------------------------------

def testOutDir : System.FilePath := "tmp"

def assertBEq [Repr α] [BEq α] (expected actual : α) : IO PUnit := do
  unless expected == actual do
    throw <| IO.userError s!"expected '{repr expected}', got '{repr actual}'"

def compileAndRunModule (mod : ModuleRef) (fname : String) : IO IO.Process.Output := do
    IO.FS.createDirAll testOutDir
    let file := testOutDir / fname
    let bcFile := file.withExtension "bc" |>.toString
    let asmFile := file.withExtension "s" |>.toString
    let exeFile := file.withExtension System.FilePath.exeExtension |>.toString
    -- Output Bitcode
    mod.writeBitcodeToFile bcFile
    -- Compile and Run It
    let llc ← IO.Process.spawn {
      cmd := "llc"
      args := #["-o", asmFile, bcFile]
    }
    let exitCode ← llc.wait
    unless exitCode == 0 do
      throw <| IO.userError s!"llc exited with error code {exitCode}"
    let cc ← IO.Process.spawn {
      cmd := "cc"
      args := #["-o", exeFile, asmFile]
    }
    let exitCode ← cc.wait
    unless exitCode == 0 do
      throw <| IO.userError s!"cc exited with error code {exitCode}"
    IO.Process.output {cmd := exeFile}

--------------------------------------------------------------------------------
-- # Exiting Program
--------------------------------------------------------------------------------

def testSimpleExitingProgram : LlvmM PUnit := do

    -- Construct Module
    let exitCode := 101
    let mod ← ModuleRef.new "exit"
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
    if (← mod.verify) then
      throw <| IO.userError "failed to verify exiting module"

    -- Run It
    let ee ← ExecutionEngineRef.createForModule mod
    let ret ← ee.runFunction fn #[]
    let exitCode ← ret.toInt
    unless exitCode == 101 do
      throw <| IO.userError s!"JIT returned exit code {exitCode}"

    -- Output It
    let out ← compileAndRunModule mod "exit"
    unless out.exitCode == 101 do
      throw <| IO.userError s!"program exited with code {out.exitCode}"

--------------------------------------------------------------------------------
-- # Hello World Program
--------------------------------------------------------------------------------

def testHelloWorldProgram : LlvmM PUnit := do

    -- Construct Module
    let mod ← ModuleRef.new "hello"

    -- Initialize Hello String Constant
    let hello := "Hello World!"
    let helloGbl ← GlobalVariableRef.ofString hello
    let intTypeRef ← IntegerTypeRef.get 32
    let z ← intTypeRef.getConstantNat 0
    let helloPtr ← ConstantExprRef.getGetElementPtr helloGbl #[z, z] true
    mod.appendGlobalVariable helloGbl

    -- Declare `printf` function
    let stringTypeRef ← PointerTypeRef.get (← IntegerTypeRef.get 8)
    let printfFnTy ← FunctionTypeRef.get intTypeRef #[stringTypeRef] true
    let printf ← FunctionRef.create printfFnTy "printf"
    mod.appendFunction printf

    -- Add Main Function
    let mainFnTy ← FunctionTypeRef.get intTypeRef #[]
    let main ← FunctionRef.create mainFnTy "main"
    mod.appendFunction main
    let bb ← BasicBlockRef.create
    main.appendBasicBlock bb
    let call ← printf.createCall #[helloPtr]
    bb.appendInstruction call
    let ret ← ReturnInstRef.createUInt32 0
    bb.appendInstruction ret

    -- Verify, Compile, and Run Module
    if (← mod.verify) then
      throw <| IO.userError "failed to verify hello world module"
    let out ← compileAndRunModule mod "hello"
    unless out.exitCode == 0 do
      throw <| IO.userError s!"program exited with code {out.exitCode}"
    assertBEq hello out.stdout

--------------------------------------------------------------------------------
-- # Runner
--------------------------------------------------------------------------------

def main : IO PUnit := do
  if (← initNativeTarget) then
    throw <| IO.userError "failed to initialize native target"
  if (← initNativeAsmPrinter) then
    throw <| IO.userError "failed to initialize native asm printer"

  LlvmM.run do
    IO.println "Testing exiting program ... "
    testSimpleExitingProgram
    IO.println "Testing hello world program ... "
    testHelloWorldProgram
