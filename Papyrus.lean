import Papyrus.Module

open Papyrus

def main : IO Unit := LLVM.run do
  let mod ← ModuleRef.new "hello"
  IO.println (← mod.getModuleID)
  mod.setModuleID "world"
  IO.println (← mod.getModuleID)
