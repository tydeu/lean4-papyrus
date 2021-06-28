import Papyrus.Context
import Papyrus.IR.Function

namespace Papyrus

-- # Module References

/--
  A reference to the LLVM representation of a
  [Module](https://llvm.org/doxygen/classllvm_1_1Module.html).
-/
constant ModuleRef : Type := Unit

namespace ModuleRef

/-- Create a new module. -/
@[extern "papyrus_module_new"]
constant new (modID : @& String) : LLVM ModuleRef

/-- Get the module's identifier (which is, essentially, its name). -/
@[extern "papyrus_module_get_id"]
constant getModuleID (self : @& ModuleRef) : IO String

/-- Set the module's identifier. -/
@[extern "papyrus_module_set_id"]
constant setModuleID (self : @& ModuleRef) (modID : @& String) : IO PUnit

/-- Get an array of references to the functions of this module . -/
@[extern "papyrus_module_get_functions"]
constant getFunctions (self : @& ModuleRef) : IO (Array FunctionRef)

/-- Add a function to the end of this module . -/
@[extern "papyrus_module_append_function"]
constant appendFunction (fn : @& FunctionRef) (self : @& ModuleRef) : IO PUnit

/-- Print the IR of this value to standard error for debugging. -/
@[extern "papyrus_module_dump"]
constant dump (self : @& ModuleRef) : IO PUnit

end ModuleRef

-- # Pure Modules

structure Module where
  moduleID : String

namespace Module

def mkRef (self : Module) : LLVM ModuleRef :=
  ModuleRef.new self.moduleID

end Module
