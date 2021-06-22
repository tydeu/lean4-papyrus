import Papyrus.LLVM.Context

namespace Papyrus.LLVM

constant Module : Type := Unit

@[extern "papyrus_module_new"]
constant Context.newModule (name : @& String) (ctx : Context) : IO Module

namespace Module

@[extern "papyrus_module_getModuleIdentifier"]
constant getModuleIdentifier (mod : @& Module) : IO String
