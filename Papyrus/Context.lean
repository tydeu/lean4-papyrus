namespace Papyrus

/--
  A reference to the LLVM representation of a
  [LLVMContext](https://llvm.org/doxygen/classllvm_1_1LLVMContext.html).
-/
constant ContextRef : Type := Unit

/-- Create a new LLVM context. -/
@[extern "papyrus_context_new"]
constant ContextRef.new : IO ContextRef

/-- The LLVM Monad. -/
abbrev LLVM := ReaderT ContextRef IO

namespace LLVM

def runIn (ctx : ContextRef) (self : LLVM α) : IO α :=
  self ctx

def run (self : LLVM α) : IO α := do
  self (← ContextRef.new)
