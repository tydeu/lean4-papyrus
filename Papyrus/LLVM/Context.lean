namespace Papyrus.LLVM

constant Context : Type := Unit

@[extern "papyrus_context_new"]
constant newContext : IO Context
