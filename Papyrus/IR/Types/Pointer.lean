import Papyrus.IR.AddressSpace
import Papyrus.IR.Types.TypeRef

namespace Papyrus

-- # Pointer Type Reference

/--
  A reference to the LLVM representation of a
  [PointerType](https://llvm.org/doxygen/classllvm_1_1PointerType.html).
-/
def PointerTypeRef := TypeRef

namespace PointerTypeRef

/--
  Get a reference to the LLVM pointer type of
    the given pointee type in the given raw address space.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_pointer_type"]
constant getRaw (pointeeType : @& TypeRef) (addrSpace : UInt32) : IO PointerTypeRef

/--
  Get a reference to the LLVM pointer type of
    the given pointee type in the given address space.
  It is the user's responsibility to ensure they are valid.
-/
def get (pointeeType : TypeRef) (addrSpace := AddressSpace.default) : IO PointerTypeRef :=
  getRaw pointeeType addrSpace.toUInt32

/-- Get a reference to the type pointed to by this type. -/
@[extern "papyrus_pointer_type_get_pointee_type"]
constant getPointeeType (self : @& PointerTypeRef) : IO TypeRef

/-- Get the raw mumerical address space of this pointer type. -/
@[extern "papyrus_pointer_type_get_address_space"]
constant getRawAddressSpace (self : @& PointerTypeRef) : IO UInt32

/-- Get the address space of this pointer type. -/
@[extern "papyrus_pointer_type_get_address_space"]
constant getAddressSpace (self : @& PointerTypeRef) : IO AddressSpace

end PointerTypeRef

-- # Pure Pointer Type

/-- A pointer type in a specific address space. -/
structure PointerType (α) (addrSpace := AddressSpace.default) where
  pointeeType : α

/--
  A pointer type to the given type
  in the given address space (or the default one).
-/
def pointerType (pointeeType : α) (addrSpace := AddressSpace.default) :=
  (PointerType.mk pointeeType : PointerType α addrSpace)

namespace PointerType
variable {addrSpace : AddressSpace}

/-- The address space of this pointer type. -/
def addressSpace (self : PointerType α addrSpace) := addrSpace

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the pointee type
    and address space are valid.
-/
def getRef [ToTypeRef α] (self : PointerType α addrSpace) : LLVM PointerTypeRef := do
  PointerTypeRef.get (← toTypeRef self.pointeeType) self.addressSpace

end PointerType

instance [ToTypeRef α] {addrSpace} : ToTypeRef (PointerType α addrSpace) :=
  ⟨PointerType.getRef⟩
