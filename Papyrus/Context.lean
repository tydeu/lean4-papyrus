import Papyrus.FFI

namespace Papyrus

/--
  An opaque type representing an external
  [LLVMContext](https://llvm.org/doxygen/classllvm_1_1LLVMContext.html).
-/
constant LLVMContext : Type := Unit

/--
  A reference to an external
  [LLVMContext](https://llvm.org/doxygen/classllvm_1_1LLVMContext.html).
-/
def ContextRef := OwnedPtr LLVMContext

/-- Create a new LLVM context. -/
@[extern "papyrus_context_new"]
constant ContextRef.new : IO ContextRef

/-- The LLVM Monad. -/
abbrev LlvmM := ReaderT ContextRef IO

namespace LlvmM

protected def runIn (ctx : ContextRef) (self : LlvmM α) : IO α :=
  self ctx

protected def run (self : LlvmM α) : IO α := do
  self (← ContextRef.new)
