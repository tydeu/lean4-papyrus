import Papyrus.Types
import Papyrus.Module

open Papyrus

deriving instance Repr for TypeID

def main : IO Unit := LLVM.run do

  -- Test Module
  let mod ← ModuleRef.new "hello"
  IO.println (← mod.getModuleID)
  mod.setModuleID "world"
  IO.println (← mod.getModuleID)

  -- Test Types
  IO.println <| repr (← (← getVoidType).getTypeID)
  IO.println <| repr (← (← getHalfType).getTypeID)
  IO.println <| repr (← (← getFloatType).getTypeID)
  IO.println <| repr (← (← getDoubleType).getTypeID)
