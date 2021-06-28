import Papyrus.IR.Types.TypeRef

namespace Papyrus

--------------------------------------------------------------------------------
-- Struct Type References
--------------------------------------------------------------------------------

/--
  A reference to the LLVM representation of a
  [StructType](https://llvm.org/doxygen/classllvm_1_1StructType.html).
-/
def StructTypeRef := TypeRef

namespace StructTypeRef

/-- Get whether this struct type is literal. -/
@[extern "papyrus_struct_type_is_literal"]
constant isLiteral (self : @& StructTypeRef) : IO Bool

/-- Get whether this struct type is non-literal and opaque. -/
@[extern "papyrus_struct_type_is_opaque"]
constant isOpaque (self : @& StructTypeRef) : IO Bool

/-- Get an array of references to the element types of this *non-opaque* struct type. -/
@[extern "papyrus_struct_type_get_element_types"]
constant getElementTypes (self : @& StructTypeRef) : IO (Array TypeRef)

/-- Get whether this struct type is non-opaque and packed. -/
@[extern "papyrus_struct_type_is_packed"]
constant isPacked (self : @& StructTypeRef) : IO Bool

end StructTypeRef

-- # Literal Struct Type References

/--
  A reference to the LLVM representation of a literal
  [StructType](https://llvm.org/doxygen/classllvm_1_1StructType.html).

  Literal struct types (e.g., `{ i32, i32 }`) are uniqued structurally,
    and must always have a body when created.
-/
def LiteralStructTypeRef := StructTypeRef

namespace LiteralStructTypeRef

/--
  Get a reference to the LLVM literal struct type of
    with the given element types and packing.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_literal_struct_type"]
constant get (elemTypes : @& Array TypeRef) (isPacked := false)
  : LLVM LiteralStructTypeRef

end LiteralStructTypeRef

-- # Identified Struct Type References

/--
  A reference to the LLVM representation of a identified
  [StructType](https://llvm.org/doxygen/classllvm_1_1StructType.html).

  Identified structs may optionally have a name and are not uniqued.
  The names for identified structs are managed at the context level,
    so there can only be a single identified struct with a given name in
    a particular context.
  Identified structs may also optionally be opaque (have no body specified).
-/
def IdentifiedStructTypeRef := StructTypeRef

namespace IdentifiedStructTypeRef

/--
  Create a new struct type
    with the given name, element types, and packing.
  It is the user's responsibility to ensure they are valid.
  Passing the empty name string will leave the type unnamed.
-/
@[extern "papyrus_create_complete_struct_type"]
private constant create (name : @& String) (elementTypes : @& Array TypeRef)
  (packed := false) : LLVM IdentifiedStructTypeRef

/--
  Create a new opaque struct type with the given name
  (or none if the name string is empty).
-/
@[extern "papyrus_create_opaque_struct_type"]
constant createOpaque (name : @& String) : LLVM IdentifiedStructTypeRef

/-- Get the name of this struct type (or the empty string if none). -/
@[extern "papyrus_struct_type_get_name"]
constant getName (self : @& IdentifiedStructTypeRef) : IO String

/--
  Set the name of this struct type.
  Passing the empty string will remove the type's name.
  The name may also have a suffix appended if it a collides with another
  in the same context.
-/
@[extern "papyrus_struct_type_set_name"]
constant setName (name : @& String) (self : @& IdentifiedStructTypeRef) : IO PUnit

/-- Removes the name of this struct type. -/
def removeName (self : IdentifiedStructTypeRef) := setName "" self

/--
  Set the body of this *opaque* struct type,
  making it a now a complete struct type.
-/
@[extern "papyrus_opaque_struct_type_set_body"]
constant setBody (elemTypes : @& Array TypeRef) (self : @& IdentifiedStructTypeRef)
  (isPacked := false)  : IO PUnit

end IdentifiedStructTypeRef

--------------------------------------------------------------------------------
-- Pure Struct Types
--------------------------------------------------------------------------------

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
