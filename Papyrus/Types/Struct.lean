import Papyrus.Types.TypeRef

namespace Papyrus

-- # Complete Struct

/-- A named, complete struct type. -/
structure StructType (name : String) (α) (isPacked : Bool) where
  elementTypes : α

/-- A struct type with the given name, element types, and packing. -/
def structType (name : String) (elementTypes : α) (packed := false) :=
  (StructType.mk elementTypes : StructType name α packed)

@[extern "papyrus_get_struct_type"]
private constant getStructTypeRef
  (name : @& String) (elementTypes : @& Array TypeRef) (packed : Bool) : LLVM TypeRef

namespace StructType
variable {name : String} {packed : Bool}

/-- The name which identifies the struct type. -/
def name {n : String} {p : Bool} (self : StructType n β p) := n

/-- Is this struct type packed? -/
def isPacked (self : StructType name β packed) := packed

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element types are valid.
-/
def getRef [ToTypeRefArray α] (self : StructType name α packed) : LLVM TypeRef := do
  getStructTypeRef name (← toTypeRefArray self.elementTypes) packed

end StructType

instance [ToTypeRefArray α] {name packed} : ToTypeRef (StructType name α packed) :=
  ⟨StructType.getRef⟩

-- # Opaque Struct

/-- An opaque named struct type. -/
structure OpaqueStructType (name : String) deriving Inhabited

/-- A opaque struct type with the given name. -/
def opaqueStructType (name : String) : OpaqueStructType name :=
  OpaqueStructType.mk

@[extern "papyrus_get_opaque_struct_type"]
private constant getOpaqueStructTypeRef (name : @& String) : LLVM TypeRef

namespace OpaqueStructType
variable {name : String}

/-- The name which identifies the struct type. -/
def name {n : String} (self : OpaqueStructType n) := n

/-- Get a reference to the LLVM representation of this type. -/
def getRef (self : OpaqueStructType name) : LLVM TypeRef := do
  getOpaqueStructTypeRef name

end OpaqueStructType

instance {name} : ToTypeRef (OpaqueStructType name) :=
  ⟨OpaqueStructType.getRef⟩

-- # Literal Struct

/--
  A literal struct type.
  Two literal struct types are equivalnet if they jave the same structure
  (i.e., their elements are equivalent).
-/
structure LiteralStructType (α) (isPacked : Bool) where
  elementTypes : α

/-- A literal struct type with the given element types and packing. -/
def literalStructType (elementTypes : α) (packed := false) :=
  (LiteralStructType.mk elementTypes : LiteralStructType α packed)

@[extern "papyrus_get_literal_struct_type"]
private constant getLiteralStructTypeRef
  (elementTypes : @& Array TypeRef) (packed : Bool) : LLVM TypeRef

namespace LiteralStructType
variable {packed : Bool}

/-- Is this struct type packed? -/
def isPacked (self : LiteralStructType β packed) := packed

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element types are valid.
-/
def getRef [ToTypeRefArray α] (self : LiteralStructType α packed) : LLVM TypeRef := do
  getLiteralStructTypeRef (← toTypeRefArray self.elementTypes) packed

end LiteralStructType

instance [ToTypeRefArray α] {packed} : ToTypeRef (LiteralStructType α packed) :=
  ⟨LiteralStructType.getRef⟩
