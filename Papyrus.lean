import Papyrus.LLVM.Context
import Papyrus.LLVM.Module

open Papyrus

def main : IO Unit := do
  let ctx ← LLVM.newContext
  let mod ← ctx.newModule "hello"
  IO.println (← mod.getModuleIdentifier)
