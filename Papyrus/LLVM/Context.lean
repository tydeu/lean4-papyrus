namespace Papyrus.LLVM

constant Context : Type := Unit

@[extern "lean_llvm_context_new"]
constant newContext : IO Context
