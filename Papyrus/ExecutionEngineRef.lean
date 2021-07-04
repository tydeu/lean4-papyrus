import Papyrus.IR.ModuleRef
import Papyrus.IR.FunctionRef
import Papyrus.GenericValueRef

namespace Papyrus

/-- A desired execution engine kind. -/
inductive EngineKind
| Either
| JIT
| Interpreter
deriving BEq, Repr

attribute [unbox] EngineKind
instance : Inhabited EngineKind := ⟨EngineKind.Either⟩

namespace EngineKind

def isJIT (self : EngineKind) : Bool :=
  self matches JIT

def allowsJIT : (self : EngineKind) → Bool
| JIT => true
| Interpreter => false
| Either => true

def isInterpreter (self : EngineKind) : Bool :=
  self matches Interpreter

def allowsInterpreter : (self : EngineKind) → Bool
| JIT => false
| Interpreter => true
| Either => true

def isEither (self : EngineKind) : Bool :=
  self matches Either

def ofUInt8 (value : UInt8) : EngineKind :=
  if value == 0b01 then JIT else
  if value == 0b10 then Interpreter else
  Either

def toUInt8 : (self : EngineKind) → UInt8
| JIT => 0b01
| Interpreter => 0b10
| Either => 0b11

end EngineKind

/-- Optimization level for generated code. -/
inductive OptLevel
| /-- -O0 -/ None
| /-- -O1 -/ Less
| /-- -O2 -/ Default
| /-- -O3 -/ Aggressive
deriving BEq, Repr

attribute [unbox] OptLevel
instance : Inhabited OptLevel := ⟨OptLevel.Default⟩

/--
  A reference to an external LLVM
  [ExecutionEngine](https://llvm.org/doxygen/classllvm_1_1ExecutionEngine.html).
-/
constant ExecutionEngineRef : Type := Unit

namespace ExecutionEngineRef

/-- Create an execution engine for the given module. -/
@[extern "papyrus_execution_engine_create_for_module"]
constant createForModule (mod : @& ModuleRef) (kind : @& EngineKind := EngineKind.Either)
  (march : @& String := "") (mcpu : @& String := "") (mattrs : @& Array String := #[])
  (optLevel : @& OptLevel := OptLevel.Default) (verifyModule := false)
  : IO ExecutionEngineRef

/--
  Execute the given function with the given arguments, and return the result.

  MCJIT execution engines can only execute 'main-like' function.
  That is, those returning `void` or `int` and taking no arguments
  (i.e., `[]`) or argc/argv (i.e., `[int, char**]`).
-/
@[extern "papyrus_execution_engine_run_function"]
constant runFunction (fn : @& FunctionRef) (args : @& Array GenericValueRef)
  (self : @& ExecutionEngineRef) : IO GenericValueRef

end ExecutionEngineRef
