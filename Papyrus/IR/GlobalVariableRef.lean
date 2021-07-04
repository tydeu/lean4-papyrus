import Papyrus.Context
import Papyrus.IR.GlobalRefs
import Papyrus.IR.AddressSpace
import Papyrus.IR.ConstantRef
import Papyrus.IR.TypeRef

namespace Papyrus

/--
  A reference to an external LLVM
  [GlobalVariable](https://llvm.org/doxygen/classllvm_1_1GlobalVariable.html).
-/
def GlobalVariableRef := GlobalObjectRef

namespace GlobalVariableRef

/-- Create a new unlinked global variable. -/
@[extern "papyrus_global_variable_new"]
constant newRaw (type : @& TypeRef) (isConstant := false) (linkage := Linkage.external)
  (name : @& String := "") (tlm := ThreadLocalMode.notLocal) (addrSpace : UInt32 := 0)
  (isExternallyInitialized := false) : IO GlobalVariableRef

/-- Create a new unlinked global variable. -/
def new (type : @& TypeRef) (isConstant : Bool)
(linkage := Linkage.external) (name : @& String := "") (tlm := ThreadLocalMode.notLocal)
(addrSpace : @& AddressSpace := AddressSpace.default) (isExternallyInitialized := false)
: IO GlobalVariableRef :=
  newRaw type isConstant linkage name tlm addrSpace.toUInt32
    isExternallyInitialized

/-- Create a new unlinked global variable with an initializer. -/
@[extern "papyrus_global_variable_new_with_init"]
constant newWithInitRaw (type : @& TypeRef) (isConstant := false)
  (linkage := Linkage.external) (init : @& ConstantRef) (name : @& String := "")
  (tlm := ThreadLocalMode.notLocal) (addrSpace : UInt32 := 0)
  (isExternallyInitialized := false) : IO GlobalVariableRef

/-- Create a new unlinked global variable with an initializer. -/
def newWithInit (type : @& TypeRef) (isConstant := false)
(linkage := Linkage.external) (init : @& ConstantRef) (name : @& String := "")
(tlm := ThreadLocalMode.notLocal) (addrSpace : @& AddressSpace := AddressSpace.default)
(isExternallyInitialized := false)
: IO GlobalVariableRef := do
  newWithInitRaw type isConstant linkage init name tlm addrSpace.toUInt32
    isExternallyInitialized

/--
  Get whether the this global variable is constant
  (i.e., its value does not change at runtime).
-/
@[extern "papyrus_global_variable_is_constant"]
constant isConstant (self : @& GlobalValueRef) : IO Bool

/--
  Set whether the this global variable is constant
  (i.e., its value does not change at runtime).
-/
@[extern "papyrus_global_variable_set_constant"]
constant setConstant (isConstant : Bool) (self : @& GlobalVariableRef) : IO PUnit

/-- Get whether the this global variable has an initializer. -/
@[extern "papyrus_global_variable_has_initializer"]
constant hasInitializer (self : @& GlobalVariableRef) : IO Bool

/--
  Get the initializer of this global variable.
  Only call this if it is know to have one (i.e., `hasInitializer` returned true).
-/
@[extern "papyrus_global_variable_get_initializer"]
constant getInitializer (self : @& GlobalVariableRef)
  : IO ConstantRef

/-- Set the initializer of this global variable. -/
@[extern "papyrus_global_variable_set_initializer"]
constant setInitializer (init : @& ConstantRef)
  (self : @& GlobalVariableRef) : IO PUnit

/-- Remove the initializer of this global variable. -/
@[extern "papyrus_global_variable_remove_initializer"]
constant removeInitializer (self : @& GlobalVariableRef) : IO PUnit

/-- Get whether the this global variable is externally initialized. -/
@[extern "papyrus_global_variable_is_externally_initialized"]
constant isExternallyInitialized (self : @& GlobalVariableRef) : IO Bool

/-- Set whether the this global variable is externally initialized. -/
@[extern "papyrus_global_variable_set_externally_initialized"]
constant setExternallyInitialized (externallyInitialized : Bool)
  (self : @& GlobalVariableRef) : IO Bool

end GlobalVariableRef
