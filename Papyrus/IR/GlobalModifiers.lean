namespace Papyrus

--------------------------------------------------------------------------------
-- # Linkage
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- # Visibility
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- # DLL Storage Class
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- # Thread Local Mode
--------------------------------------------------------------------------------

/--
  A global may be defined as thread local, which means that it will not be
  shared by threads (each thread will have a separated copy of the variable).

  A thread local global can define a preferred thread local storage  model, see
  [ELF Handling for Thread-Local Storage](http://people.redhat.com/drepper/tls.pdf)
  for more information on the how they be used.

  Not all targets support thread-local variables.
-/
inductive ThreadLocalMode
| /-- Global is not thread local. -/
  notLocal
| /-- General case, the default for a thread local global. -/
  generalDynamic
| /-- Only used within the current shared library. -/
  localDynamic
| /-- Not loaded dynamically. -/
  initialExec
| /-- Defined in the executable and only used within it. -/
  localExec
deriving BEq, DecidableEq, Repr

attribute [unbox] ThreadLocalMode
instance : Inhabited ThreadLocalMode := ⟨ThreadLocalMode.notLocal⟩

--------------------------------------------------------------------------------
-- # Address Significance
--------------------------------------------------------------------------------

/--
  The significance of a global's address in memory.
  A global with an insignificant address can be merged with an equivalent global.

  This is conceptually the opposite of LLVM's
  [UnnamedAddr](https://llvm.org/doxygen/classllvm_1_1GlobalValue.html#ae8df4be75bfc50b1eadd74e85c25fa45),
  enumeration, but order is preserved across the two by reversing the enumeration.
  It has been renamed to make its use clearer.
-/
inductive AddressSignificance
| /-- Significant everywhere (the default). -/
  total
| /-- Significant only outside the current module. -/
  external
| /-- Insignificant everywhere. -/
  protected none
deriving BEq, DecidableEq, Repr

attribute [unbox] AddressSignificance
instance : Inhabited AddressSignificance := ⟨AddressSignificance.total⟩
