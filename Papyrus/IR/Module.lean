import Papyrus.Context

namespace Papyrus

-- # Module References

/--
  A reference to the LLVM representation of a
  [Module](https://llvm.org/doxygen/classllvm_1_1Module.html).
-/
constant ModuleRef : Type := Unit

namespace ModuleRef

@[extern "papyrus_module_new"]
constant new (modID : @& String) : LLVM ModuleRef

@[extern "papyrus_module_get_id"]
constant getModuleID (self : @& ModuleRef) : IO String

@[extern "papyrus_module_set_id"]
constant setModuleID (self : @& ModuleRef) (modID : @& String) : IO Unit

end ModuleRef

-- # Pure Modules

structure Module where
  moduleID : String

namespace Module

def mkRef (self : Module) : LLVM ModuleRef :=
  ModuleRef.new self.moduleID

end Module
