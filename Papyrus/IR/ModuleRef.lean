import Papyrus.Context
import Papyrus.MemoryBufferRef
import Papyrus.IR.FunctionRef

namespace Papyrus

/--
  A reference to the LLVM representation of a
  [Module](https://llvm.org/doxygen/classllvm_1_1Module.html).
-/
constant ModuleRef : Type := Unit

namespace ModuleRef

/-- Create a new module. -/
@[extern "papyrus_module_new"]
constant new (modID : @& String) : LLVM ModuleRef

/-- Load module from a bitcode memory buffer. -/
@[extern "papyrus_module_parse_bitcode_from_buffer"]
constant parseBitcodeFromBuffer (self : @& MemoryBufferRef) : LLVM ModuleRef

/-- Load module from a bitcode file.  -/
def parseBitcodeFromFile (file : System.FilePath) : LLVM ModuleRef := do
  parseBitcodeFromBuffer (← MemoryBufferRef.fromFile file)

/--
  Write the bitcode of the module to a file.
  If `preserveUseListOrder` is set, the use-list order for each
    Value in the module will be encoded in the bitcode.
  These will then be reconstructed exactly when it is deserialized.
-/
@[extern "papyrus_module_write_bitcode_to_file"]
constant writeBitcodeToFile (file : @& System.FilePath) (self : @& ModuleRef)
  (preserveUseListOrder := false) : IO PUnit

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

/-- Check the module for errors (returns *true* if any errors are found). -/
@[extern "papyrus_module_verify"]
constant verify (self : @& ModuleRef) : IO Bool

/-- Print the IR of this value to standard error for debugging. -/
@[extern "papyrus_module_dump"]
constant dump (self : @& ModuleRef) : IO PUnit

end ModuleRef
