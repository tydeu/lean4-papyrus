import Papyrus.IR.ModuleRef
import Papyrus.IR.FunctionRef
import Papyrus.GenericValueRef

namespace Papyrus

/-- A desired execution engine kind. -/
inductive EngineKind
| either
| jit
| interpreter
deriving BEq, DecidableEq, Repr

attribute [unbox] EngineKind
instance : Inhabited EngineKind := ⟨EngineKind.either⟩

namespace EngineKind

def isJit (self : EngineKind) : Bool :=
  self matches jit

def allowsJit : (self : EngineKind) → Bool
| jit => true
| interpreter => false
| either => true

def isInterpreter (self : EngineKind) : Bool :=
  self matches interpreter

def allowsInterpreter : (self : EngineKind) → Bool
| jit => false
| interpreter => true
| either => true

def isEither (self : EngineKind) : Bool :=
  self matches either

def ofUInt8 (value : UInt8) : EngineKind :=
  if value == 0b01 then jit else
  if value == 0b10 then interpreter else
  either

def toUInt8 : (self : EngineKind) → UInt8
| jit => 0b01
| interpreter => 0b10
| either => 0b11

end EngineKind

/-- Optimization level for generated code. -/
inductive OptLevel
| /-- -O0 -/ none
| /-- -O1 -/ less
| /-- -O2 -/ default
| /-- -O3 -/ aggressive
deriving BEq, DecidableEq, Repr

attribute [unbox] OptLevel
instance : Inhabited OptLevel := ⟨OptLevel.default⟩

/--
  A reference to an external LLVM
  [ExecutionEngine](https://llvm.org/doxygen/classllvm_1_1ExecutionEngine.html).
-/
constant ExecutionEngineRef : Type := Unit

namespace ExecutionEngineRef

/-- Create an execution engine for the given module. -/
@[extern "papyrus_execution_engine_create_for_module"]
constant createForModule (mod : @& ModuleRef) (kind : @& EngineKind := EngineKind.either)
  (march : @& String := "") (mcpu : @& String := "") (mattrs : @& Array String := #[])
  (optLevel : @& OptLevel := OptLevel.default) (verifyModule := false)
  : IO ExecutionEngineRef

/--
  Execute the given function with the given arguments, and return the result.

  An MCJIT execution engine can only execute 'main-like' function.
  That is, those returning `void` or `int` and taking no arguments
  (i.e., `[]`) or `argc`/`argv` (i.e., `[i32, i8**]`).
-/
@[extern "papyrus_execution_engine_run_function"]
constant runFunction (fn : @& FunctionRef) (self : @& ExecutionEngineRef)
  (args : @& Array GenericValueRef := #[]) : IO GenericValueRef

/--
  A helper for `runFunction` that runs a standard  `main`-like function.
  That is, a function that may take up to three arguments  (`i32 argc`,
  `i8** argv`, and `i8** envp`) and return a `i32` exit code.
-/
@[extern "papyrus_execution_engine_run_function_as_main"]
constant runFunctionAsMain (fn : @& FunctionRef) (self : @& ExecutionEngineRef)
  (args : @& Array String := #[]) (env : @& Array String := #[]) : IO UInt32

end ExecutionEngineRef
