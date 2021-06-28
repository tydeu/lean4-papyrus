import Papyrus.IR.TypeRefs

namespace Papyrus

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
