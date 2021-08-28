import Papyrus.FFI
import Papyrus.Context
import Papyrus.MemoryBufferRef
import Papyrus.IR.GlobalVariableRef
import Papyrus.IR.FunctionRef

namespace Papyrus

/--
  A opaque type representing an external LLVM
  [Module](https://llvm.org/doxygen/classllvm_1_1Module.html).
-/
constant Llvm.Module : Type := Unit

/--
  A reference to an external LLVM
  [Module](https://llvm.org/doxygen/classllvm_1_1Module.html).
-/
def ModuleRef := LinkedLoosePtr ContextRef Llvm.Module

namespace ModuleRef

/-- Create a new module. -/
@[extern "papyrus_module_new"]
constant new (modID : @& String) : LlvmM ModuleRef

/-- Load module from a bitcode memory buffer. -/
@[extern "papyrus_module_parse_bitcode_from_buffer"]
constant parseBitcodeFromBuffer (self : @& MemoryBufferRef) : LlvmM ModuleRef

/-- Load module from a bitcode file.  -/
def parseBitcodeFromFile (file : System.FilePath) : LlvmM ModuleRef := do
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

/--
  Get the function of the given name in this module (if it exists).

  If `allowInternal` is set to true, this function will return globals
  that have internal linkage. By default, they are not returned.
-/
@[extern "papyrus_module_get_global_variable"]
constant getGlobalVariable? (name : @& String) (self : @& ModuleRef)
  (allowInternal := false) : IO (Option GlobalVariableRef)

/-- Get an array of references to the global variables of this module. -/
@[extern "papyrus_module_get_global_variables"]
constant getGlobalVariables (self : @& ModuleRef) : IO (Array GlobalVariableRef)

/-- Add a global variable to the end of this module . -/
@[extern "papyrus_module_append_global_variable"]
constant appendGlobalVariable (var : @& GlobalVariableRef) (self : @& ModuleRef) : IO PUnit

/-- Get the function of the given name in this module (if it exists). -/
@[extern "papyrus_module_get_function"]
constant getFunction? (name : @& String) (self : @& ModuleRef) : IO (Option FunctionRef)

/-- Get an array of references to the functions of this module. -/
@[extern "papyrus_module_get_functions"]
constant getFunctions (self : @& ModuleRef) : IO (Array FunctionRef)

/-- Add a function to the end of this module . -/
@[extern "papyrus_module_append_function"]
constant appendFunction (fn : @& FunctionRef) (self : @& ModuleRef) : IO PUnit

/--
  Check the module for errors. Errors are reported inside the `IO` monad.

  If `warnBrokenDebugInfo` is `true`, DebugInfo verification failures
  won't be considered as an error and instead the function will return `true`.
  Otherwise, the function will always return `false`.
-/
@[extern "papyrus_module_verify"]
constant verify (self : @& ModuleRef) (warnBrokenDebugInfo := false) : IO Bool

/--
  Print this module to LLVM's standard output (which may not correspond to Lean's).

  If`shouldPreserveUseListOrder`, the output will include `uselistorder`
  directives so that use-lists can be recreated  when reading the assembly.
-/
@[extern "papyrus_module_print"]
constant print (self : @& ModuleRef)
  (shouldPreserveUseListOrder := false) (isForDebug := false) : IO PUnit

/--
  Print this module to LLVM's standard error (which may not correspond to Lean's).

  If`shouldPreserveUseListOrder`, the output will include `uselistorder`
  directives so that use-lists can be recreated  when reading the assembly.
-/
@[extern "papyrus_module_eprint"]
constant eprint (self : @& ModuleRef)
  (shouldPreserveUseListOrder := false) (isForDebug := false) : IO PUnit

/--
  Print this module to a String.

  If`shouldPreserveUseListOrder`, the output will include `uselistorder`
  directives so that use-lists can be recreated  when reading the assembly.
-/
@[extern "papyrus_module_sprint"]
constant sprint (self : @& ModuleRef)
  (shouldPreserveUseListOrder := false) (isForDebug := false) : IO String

/-- Print this module to Lean's standard output for debugging. -/
def dump (self : @& ModuleRef) : IO PUnit := do
  IO.print (← self.sprint (isForDebug := true))

end ModuleRef
