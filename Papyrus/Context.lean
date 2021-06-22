namespace Papyrus

constant ContextRef : Type := Unit

@[extern "papyrus_context_new"]
constant ContextRef.new : IO ContextRef

/-- The LLVM Monad. -/
abbrev LLVM := ReaderT ContextRef IO

namespace LLVM

def runWith (ctx : ContextRef) (self : LLVM α) : IO α :=
  self ctx

def run (self : LLVM α) : IO α := do
  self (← ContextRef.new)
