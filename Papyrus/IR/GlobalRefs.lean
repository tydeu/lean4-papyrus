import Papyrus.Context
import Papyrus.IR.TypeRefs
import Papyrus.IR.ConstantRef
import Papyrus.IR.AddressSpace
import Papyrus.IR.GlobalModifiers

namespace Papyrus

--------------------------------------------------------------------------------
-- # Global Value References
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [GlobalValue](https://llvm.org/doxygen/classllvm_1_1GlobalValue.html).
-/
structure GlobalValueRef extends ConstantRef
instance : Coe GlobalValueRef ConstantRef := ⟨(·.toConstantRef)⟩

namespace GlobalValueRef

/--
  Get the pointer type of this global.
  Since globals are always pointers in LLVM, this is the global's actual type.
-/
def getPointerType (self : @& GlobalValueRef) : IO PointerTypeRef :=
  self.getType

/-- Get the type of this global's value.  -/
def getType (self : @& GlobalValueRef) : IO TypeRef := do
  (← self.getPointerType).getPointeeType

/-- Get the address space of this global. -/
@[extern "papyrus_global_value_get_address_space"]
constant getAddressSpace (self : @& GlobalValueRef) : IO AddressSpace

/-- Get the linkage kind of this global. -/
@[extern "papyrus_global_value_get_linkage"]
constant getLinkage (self : @& GlobalValueRef) : IO Linkage

/-- Set the linkage kind of this global. -/
@[extern "papyrus_global_value_set_linkage"]
constant setLinkage (linkage : Linkage)

  (self : @& GlobalValueRef) : IO PUnit
/-- Get the visibility of this global. -/
@[extern "papyrus_global_value_get_visibility"]
constant getVisibility (self : @& GlobalValueRef) : IO Visibility

/-- Set the visibility of this global. -/
@[extern "papyrus_global_value_set_visibility"]
constant setVisibility (visibility : Visibility)
  (self : @& GlobalValueRef) : IO PUnit

/-- Get the DLL storage class of this global. -/
@[extern "papyrus_global_value_get_dll_storage_class"]
constant getDLLStorageClass (self : @& GlobalValueRef)
  : IO DLLStorageClass

/-- Set the DLL storage class of this global. -/
@[extern "papyrus_global_value_set_dll_storage_class"]
constant setDLLStorageClass (dllStorageClass : DLLStorageClass)
  (self : @& GlobalValueRef) : IO PUnit

/-- Get the thread local mode of this global. -/
@[extern "papyrus_global_value_get_dll_storage_class"]
constant getThreadLocalMode (self : @& GlobalValueRef)
  : IO ThreadLocalMode

/-- Set the thread local mode of this global. -/
@[extern "papyrus_global_value_set_dll_storage_class"]
constant setThreadLocalMode (tlm : ThreadLocalMode)
  (self : @& GlobalValueRef) : IO PUnit

/-- Get the address significance of this global. -/
@[extern "papyrus_global_value_get_address_significance"]
constant getAddressSignificance (self : @& GlobalValueRef)
  : IO AddressSignificance

/-- Set the address significance of this global. -/
@[extern "papyrus_global_value_set_address_significance"]
constant setAddressSignificance (addrSig : AddressSignificance)
  (self : @& GlobalValueRef) : IO PUnit

end GlobalValueRef

--------------------------------------------------------------------------------
-- # Global Object References
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [GlobalObject](https://llvm.org/doxygen/classllvm_1_1GlobalObject.html).
-/
structure GlobalObjectRef extends GlobalValueRef
instance : Coe GlobalObjectRef GlobalValueRef := ⟨(·.toGlobalValueRef)⟩

namespace GlobalObjectRef

/-- Get whether this value has a explicitly specified linker section. -/
@[extern "papyrus_global_object_has_section"]
constant hasSection (self : @& GlobalObjectRef) : IO Bool

/-- Get the explicit linker section of this value (or the empty string if none). -/
@[extern "papyrus_global_object_get_section"]
constant getSection (self : @& GlobalObjectRef) : IO String

/--
  Set the explicit linker section of this value
  (or remove it by passing the empty string).
-/
@[extern "papyrus_global_object_set_section"]
constant setSection (sect : @& String) (self : @& GlobalObjectRef) : IO PUnit

/--
  Get the explicit power of two alignment of this value (or 0 if undefined).
  Note that for functions this is the alignment of the code,
    not the alignment of a function pointer.
-/
@[extern "papyrus_global_object_get_alignment"]
constant getRawAlignment (self : @& GlobalObjectRef) : IO UInt64

/-- Set the explicit power of two alignment of this value (or pass 0 to remove it). -/
@[extern "papyrus_global_object_set_alignment"]
constant setRawAlignment (align : UInt64) (self : @& GlobalObjectRef) : IO PUnit

end GlobalObjectRef
