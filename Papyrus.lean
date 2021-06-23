import Papyrus.Types
import Papyrus.Module

open Papyrus

deriving instance Repr for TypeID

def printLLVMRefTypeID (ref : LLVM TypeRef) : LLVM PUnit := do
  IO.println <| repr (←  (← ref).getTypeID)

def main : IO Unit := LLVM.run do

  -- Test Module
  let mod ← ModuleRef.new "hello"
  IO.println (← mod.getModuleID)
  mod.setModuleID "world"
  IO.println (← mod.getModuleID)

  -- Test Types
  printLLVMRefTypeID voidType.getRef
  printLLVMRefTypeID halfType.getRef
  printLLVMRefTypeID floatType.getRef
  printLLVMRefTypeID doubleType.getRef
  printLLVMRefTypeID (integerType 32).getRef
  printLLVMRefTypeID doubleType.pointer.getRef
