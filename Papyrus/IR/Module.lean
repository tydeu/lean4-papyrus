import Papyrus.Context

namespace Papyrus

structure Module where
  moduleID : String

constant ModuleRef : Type := Unit

namespace ModuleRef

@[extern "papyrus_module_new"]
constant new (modID : @& String) : LLVM ModuleRef

@[extern "papyrus_module_get_id"]
constant getModuleID (self : @& ModuleRef) : IO String

@[extern "papyrus_module_set_id"]
constant setModuleID (self : @& ModuleRef) (modID : @& String) : IO Unit

end ModuleRef

namespace Module

def mkRef (self : Module) : LLVM ModuleRef :=
  ModuleRef.new self.moduleID

end Module
