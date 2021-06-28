import Papyrus.IR.TypeRefs

namespace Papyrus

-- # Literal Structs

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

namespace LiteralStructType
variable {packed : Bool}

/-- Is this struct type packed? -/
def isPacked (self : LiteralStructType β packed) := packed

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element types are valid.
-/
def getRef [ToTypeRefArray α] (self : LiteralStructType α packed) : LLVM LiteralStructTypeRef := do
  LiteralStructTypeRef.get (← toTypeRefArray self.elementTypes) packed

end LiteralStructType

instance [ToTypeRefArray α] {packed} : ToTypeRef (LiteralStructType α packed) :=
  ⟨LiteralStructType.getRef⟩

-- # Complete Stucts

/--
  A complete namable (non-literal) struct type.
  A struct type with an empty name string is treated as unnammed.
-/
structure CompleteStructType (name : String) (α) (isPacked : Bool) where
  elementTypes : α

/-- A struct type with the given optional name, element types, and packing. -/
def completeStructType (name : String) (elementTypes : α) (packed := false) :=
  (CompleteStructType.mk elementTypes : CompleteStructType name α packed)

namespace CompleteStructType
variable {name : String} {packed : Bool}

/-- The name which identifies the struct type (or the empty string if none). -/
def name {n : String} {p : Bool} (self : CompleteStructType n β p) := n

/-- Is this struct type packed? -/
def isPacked (self : CompleteStructType name β packed) := packed

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element types are valid.
-/
def getRef [ToTypeRefArray α] (self : CompleteStructType name α packed) : LLVM IdentifiedStructTypeRef := do
  IdentifiedStructTypeRef.create name (← toTypeRefArray self.elementTypes) packed

end CompleteStructType

instance [ToTypeRefArray α] {name packed} : ToTypeRef (CompleteStructType name α packed) :=
  ⟨CompleteStructType.getRef⟩

-- # Opaque Structs

/--
  An opaque namable (non-literal) struct type.
  A struct type with an empty name string is treated as unnammed.
-/
structure OpaqueStructType (name : String) deriving Inhabited

/-- A opaque struct type with the given name (or none if empty).
-/
def opaqueStructType (name : String) : OpaqueStructType name :=
  OpaqueStructType.mk

namespace OpaqueStructType
variable {name : String}

/-- The name which identifies the struct type (or the empty string if none). -/
def name {n : String} (self : OpaqueStructType n) := n

/-- Set the body of this opaque struct type, making it a now a complete struct type. -/
def setBody (elemTypes : Array TypeRef) (self : OpaqueStructType name) (isPacked := false) :=
  completeStructType name elemTypes isPacked

/-- Get a reference to the LLVM representation of this type. -/
def getRef (self : OpaqueStructType name) : LLVM IdentifiedStructTypeRef := do
  IdentifiedStructTypeRef.createOpaque name

end OpaqueStructType

instance {name} : ToTypeRef (OpaqueStructType name) :=
  ⟨OpaqueStructType.getRef⟩
