namespace LLVM

constant Context : Type := Unit
constant Module : Type := Unit

@[extern "lean_llvm_context_new"]
constant newContext : IO Context

@[extern "lean_llvm_module_new"]
constant Context.newModule : String → Context → IO Module

@[extern "lean_llvm_module_getModuleIdentifier"]
constant Module.getModuleIdentifier : Module → IO String

end LLVM

def main : IO Unit := do
  let ctx ← LLVM.newContext
  let mod ← ctx.newModule "hello"
  IO.println (← mod.getModuleIdentifier)
