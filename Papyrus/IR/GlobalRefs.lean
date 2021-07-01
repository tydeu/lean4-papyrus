import Papyrus.Context
import Papyrus.IR.TypeRefs
import Papyrus.IR.ConstantRef
import Papyrus.IR.AddressSpace

namespace Papyrus

-- # Global Value References

/--
  A reference to an external LLVM
  [GlobalValue](https://llvm.org/doxygen/classllvm_1_1GlobalValue.html).
-/
def GlobalValueRef := ConstantRef

namespace GlobalValueRef

/--
  Get the pointer type of this global.
  Since globals are always pointers in LLVM, this is the global's actual type.
-/
def getPointerType (self : @& GlobalValueRef) : IO PointerTypeRef :=
  ValueRef.getType self

/-- Get the type of this global's value.  -/
def getType (self : @& GlobalValueRef) : IO TypeRef := do
  (← self.getPointerType).getPointeeType

/-- Get the raw numeric address space of this global. -/
@[extern "papyrus_global_value_get_address_space"]
constant getRawAddressSpace (self : @& GlobalValueRef) : IO UInt32

/-- Get the address space of this global. -/
@[extern "papyrus_global_value_get_address_space"]
constant getAddressSpace (self : @& GlobalValueRef) : IO AddressSpace

end GlobalValueRef

-- # Linkage

/--
  The linkage kind of a global.
  It is illegal for a global variable or function *declaration* to have any
    linkage type other than `external` or `externalWeak`.
-/
inductive Linkage
| /--
    Externally visible value (the default).
    It participates in linkage and can be used to resolve
      external symbol references.
  -/
  external
| /--
    Available for inspection, not emission.
  -/
  availableExternally
| /--
    Keep any one copy of the value when linking.
    Unreferenced globals are allowed to be discarded.
  -/
  linkOnceAny
| /--
    Same as `LinkOnceAny`, but only replaced by something equivalent
    That is, it follows the "one definition rule" (ODR) ala C++.
  -/
  linkOnceODR
| /--
    Keep one copy of the value when linking.
    Unreferenced globals are *not* allowed to be discarded.
    This is corresponds to `weak` in C.
  -/
  weakAny
| /--
    Same as `WeakAny`, but only replaced by something equivalent.
    That is, it follows the "one definition rule" (ODR) ala C++.
  -/
  weakODR
| /--
    **Only applies to global variables of a pointer to array type.**
    When two global variables with appending linkage are linked together,
      the two global arrays are appended together.
    This is the types safe LLVM equivalent of having the system linker append
      together “sections” with identical names when .o files are linked.
  -/
  appending
| /-- Rename collisions when linking (e.g., `static` in C). -/
  internal
| /-- Like `Internal`, but omit from symbol table. -/
  «private»
| /--
    The symbol is weak until linked.
    If not linked, the symbol becomes null
      instead of being an undefined reference.
    That is, it follows ELF object file model.
  -/
  externalWeak
| /--
    Similar to `WeakAny`. They are use for global tentative definitions in C.
    Common symbols may not have an explicit section, must have a zero initializer,
      and may not be marked ‘constant’.
    **Functions and aliases may not have this linkage.**
  -/
  common
deriving BEq, DecidableEq, Repr

attribute [unbox] Linkage
export Linkage (linkOnceAny linkOnceODR)
instance : Inhabited Linkage := ⟨Linkage.external⟩

/-- Get the linkage kind of this global. -/
@[extern "papyrus_global_value_get_linkage"]
constant GlobalValueRef.getLinkage (self : @& GlobalValueRef) : IO Linkage

/-- Set the linkage kind of this global. -/
@[extern "papyrus_global_value_set_linkage"]
constant GlobalValueRef.setLinkage (linkage : Linkage)
  (self : @& GlobalValueRef) : IO PUnit

-- # Visibility

/-- The visibility kind of a global. -/
inductive Visibility
| /--
    The global is visible.
    On both ELF and Darwin, default visibility means that
      the declaration is visible to other modules.
    On ELF it also means that, in shared libraries,
      the declared entity may be overridden.
  -/
  protected
  default
| /--
    The global is hidden.
    Two declarations of an object with hidden visibility refer to the same object
      if they are in the same shared object.
    Usually, hidden visibility indicates that the symbol will not be placed into
      the dynamic symbol table, so no other module (executable or shared library)
      can reference it directly.
  -/
  hidden
| /--
    The global is protected.
    On ELF, protected visibility indicates that the symbol will be placed in
      the dynamic symbol table, but that references within the defining module
      will bind to the local symbol.
    That is, the symbol cannot be overridden by another module.
  -/
  «protected»
deriving BEq, DecidableEq, Repr

attribute [unbox] Visibility
instance : Inhabited Visibility := ⟨Visibility.default⟩

/-- Get the visibility of this global. -/
@[extern "papyrus_global_value_get_visibility"]
constant GlobalValueRef.getVisibility (self : @& GlobalValueRef) : IO Visibility

/-- Set the visibility of this global. -/
@[extern "papyrus_global_value_set_visibility"]
constant GlobalValueRef.setVisibility (visibility : Visibility)
  (self : @& GlobalValueRef) : IO PUnit

-- # DLL Storage Class

/-- The storage class kind of a global for PE targets. -/
inductive DLLStorageClass
| protected
  default
| /-- Imported from a DLL. -/
  dllImport
| /-- Accessible from within a DLL. -/
  dllExport
deriving BEq, DecidableEq, Repr

attribute [unbox] DLLStorageClass
export DLLStorageClass (dllImport dllExport)
instance : Inhabited DLLStorageClass := ⟨DLLStorageClass.default⟩

/-- Get the DLL storage class of this global. -/
@[extern "papyrus_global_value_get_dll_storage_class"]
constant GlobalValueRef.getDLLStorageClass (self : @& GlobalValueRef)
  : IO DLLStorageClass

/-- Set the DLL storage class of this global. -/
@[extern "papyrus_global_value_set_dll_storage_class"]
constant GlobalValueRef.setDLLStorageClass (dllStorageClass : DLLStorageClass)
  (self : @& GlobalValueRef) : IO PUnit

-- # Address Significance

/--
  The address significance of a global.
  This is conceptually the opposite of LLVM's
  [UnnamedAddr](https://llvm.org/doxygen/classllvm_1_1GlobalValue.html#ae8df4be75bfc50b1eadd74e85c25fa45),
  enumeration, but order is preserved across the two by reversing the enumeration.
  It has been renamed to make its use clearer.
-/
inductive AddressSignificance
| /-- Significant everywhere (the default). -/
  «global»
| /-- Significant only within the current module. -/
  «local»
| /-- Insignificant everywhere. -/
  none
deriving BEq, DecidableEq, Repr

attribute [unbox] AddressSignificance
instance : Inhabited AddressSignificance := ⟨AddressSignificance.global⟩

/-- Get the address significance of this global. -/
@[extern "papyrus_global_value_get_address_significance"]
constant GlobalValueRef.getAddressSignificance (self : @& GlobalValueRef)
  : IO AddressSignificance

/-- Set the address significance of this global. -/
@[extern "papyrus_global_value_set_address_significance"]
constant GlobalValueRef.setAddressSignificance (addrSig : AddressSignificance)
  (self : @& GlobalValueRef) : IO PUnit

-- # Global Object References

/--
  A reference to an external LLVM
  [GlobalObject](https://llvm.org/doxygen/classllvm_1_1GlobalObject.html).
-/
def GlobalObjectRef := GlobalValueRef

namespace GlobalObjectRef

/-- Get whether this value has a explicitly specified linker section. -/
@[extern "papyrus_global_object_has_section"]
constant hasSection (self : @& GlobalValueRef) : IO Bool

/-- Get the explicit linker section of this value (or the empty string if none). -/
@[extern "papyrus_global_object_get_section"]
constant getSection (self : @& GlobalValueRef) : IO String

/--
  Set the explicit linker section of this value
  (or remove it by passing the empty string).
-/
@[extern "papyrus_global_object_set_section"]
constant setSection (sect : @& String) (self : @& GlobalValueRef) : IO PUnit

/--
  Get the explicit power of two alignment of this value (or 0 if undefined).
  Note that for functions this is the alignment of the code,
    not the alignment of a function pointer.
-/
@[extern "papyrus_global_object_get_align"]
constant getRawAlign (self : @& GlobalValueRef) : IO UInt64

/-- Set the explicit power of two alignment of this value (or pass 0 to remove it). -/
@[extern "papyrus_global_object_set_align"]
constant setRawAlign (align : UInt64) (self : @& GlobalValueRef) : IO PUnit

end GlobalObjectRef
