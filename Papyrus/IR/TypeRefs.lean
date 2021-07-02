import Papyrus.Context
import Papyrus.IR.TypeRef
import Papyrus.IR.AddressSpace

namespace Papyrus

--------------------------------------------------------------------------------
-- Singleton Type References
--------------------------------------------------------------------------------

-- # Special Types

/-- An empty type. -/
@[extern "papyrus_get_void_type"]
constant getVoidTypeRef : LLVM TypeRef

/-- A label type. -/
@[extern "papyrus_get_label_type"]
constant getLabelTypeRef : LLVM TypeRef

/-- A metadata type. -/
@[extern "papyrus_get_metadata_type"]
constant getMetadataTypeRef : LLVM TypeRef

/-- A token type. -/
@[extern "papyrus_get_token_type"]
constant getTokenTypeRef : LLVM TypeRef

/-- A 64-bit X86 MMX vector type. -/
@[extern "papyrus_get_x86_mmx_type"]
constant getX86MMXTypeRef : LLVM TypeRef

/-- A 8192-bit X86 AMX vector type. -/
@[extern "papyrus_get_x86_amx_type"]
constant getX86AMXTypeRef : LLVM TypeRef

-- # Floating Point Types

/-- A 16-bit floating point type. -/
@[extern "papyrus_get_half_type"]
constant getHalfTypeRef : LLVM TypeRef

/-- A 16-bit (7-bit significand) floating point type. -/
@[extern "papyrus_get_bfloat_type"]
constant getBFloatTypeRef : LLVM TypeRef

/-- A 32-bit floating point type. -/
@[extern "papyrus_get_float_type"]
constant getFloatTypeRef : LLVM TypeRef

/-- A 64-bit floating point type. -/
@[extern "papyrus_get_double_type"]
constant getDoubleTypeRef : LLVM TypeRef

/-- An X87 80-bit floating point type. -/
@[extern "papyrus_get_x86_fp80_type"]
constant getX86FP80TypeRef : LLVM TypeRef

/-- A 128-bit (112-bit significand) floating point type. -/
@[extern "papyrus_get_fp128_type"]
constant getFP128TypeRef : LLVM TypeRef

/-- A PowerPC 128-bit floating point type. -/
@[extern "papyrus_get_ppc_fp128_type"]
constant getPPCFP128TypeRef : LLVM TypeRef

--------------------------------------------------------------------------------
-- Integer Type References
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [IntegerType](https://llvm.org/doxygen/classllvm_1_1IntegerType.html).
-/
def IntegerTypeRef := TypeRef

namespace IntegerTypeRef

/-- Minimum bit width of an LLVM integer type. -/
def MIN_INT_BITS : UInt32 := 1

/-- Maximum bit width of an LLVM integer type. -/
def MAX_INT_BITS : UInt32 := 16777215 -- (1 <<< 24) - 1

/-- Holds if the given bit width is valid for an LLVM integer type. -/
def isValidBitWidth (bitWidth : UInt32) : Prop :=
  bitWidth ≥ MIN_INT_BITS ∧ bitWidth ≤ MAX_INT_BITS

/--
  Get a reference to the LLVM integer type of the given width.
  It is the user's responsible to ensure that the bit width of the type falls
  within LLVM's requirements (i.e., that `isValidBitWidth numBits` holds).
-/
@[extern "papyrus_get_integer_type"]
constant get (numBits : @& UInt32) : LLVM IntegerTypeRef

/-- Get the width in bits of this type. -/
@[extern "papyrus_integer_type_get_bit_width"]
constant getBitWidth (self : @& IntegerTypeRef) : IO UInt32

end IntegerTypeRef

--------------------------------------------------------------------------------
-- Function Type References
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [FunctionType](https://llvm.org/doxygen/classllvm_1_1FunctionType.html).
-/
def FunctionTypeRef := TypeRef

namespace FunctionTypeRef

/--
  Get a reference to the LLVM function type with
    the given result and parameter types.
  It is the user's responsibility to ensure that they are valid.
-/
@[extern "papyrus_get_function_type"]
constant get (result : @& TypeRef) (params : @& Array TypeRef)
  (isVarArg := false) : IO FunctionTypeRef

/-- Get a reference to the return type of this function type. -/
@[extern "papyrus_function_type_get_return_type"]
constant getReturnType (self : @& FunctionTypeRef) : IO TypeRef

/-- Get an array of references to the parameter types of this function type. -/
@[extern "papyrus_function_type_get_parameter_types"]
constant getParameterTypes (self : @& FunctionTypeRef) : IO (Array TypeRef)

/-- Get whether this function type accepts variable arguments. -/
@[extern "papyrus_function_type_is_var_arg"]
constant isVarArg (self : @& FunctionTypeRef) : IO Bool

end FunctionTypeRef

--------------------------------------------------------------------------------
-- Pointer Type References
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
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

--------------------------------------------------------------------------------
-- Struct Type References
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
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

-- # Literal Struct Types

/--
  A reference to an external LLVM literal
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

-- # Identified Struct Types

/--
  A reference to an external LLVM identified
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
@[extern "papyrus_struct_type_create"]
constant create (name : @& String) (elementTypes : @& Array TypeRef)
  (packed := false) : LLVM IdentifiedStructTypeRef

/--
  Create a new opaque struct type with the given name
  (or none if the name string is empty).
-/
@[extern "papyrus_opaque_struct_type_create"]
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
-- Array Type Reference
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [ArrayType](https://llvm.org/doxygen/classllvm_1_1ArrayType.html).
-/
def ArrayTypeRef := TypeRef

namespace ArrayTypeRef

/--
  Get a reference to the LLVM array type of
    the given element type with the given number of elements.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_array_type"]
constant get (elemType : @& TypeRef) (numElems : UInt64) : IO ArrayTypeRef

/-- Get a reference to the element type of this array type. -/
@[extern "papyrus_array_type_get_element_type"]
constant getElementType (self : @& ArrayTypeRef) : IO TypeRef

/-- Get the number of elements in this array type . -/
@[extern "papyrus_array_type_get_num_elements"]
constant getSize (self : @& ArrayTypeRef) : IO UInt64

end ArrayTypeRef

--------------------------------------------------------------------------------
-- Vector Type References
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [VectorType](https://llvm.org/doxygen/classllvm_1_1VectorType.html).
-/
def VectorTypeRef := TypeRef

namespace VectorTypeRef

/--
  Get a reference to the LLVM vector type of
    the given element type, element quantity, and scalability.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_vector_type"]
constant get (elemType : @& TypeRef) (elemQuant : UInt32)
  (isScalable := false) : IO VectorTypeRef

/-- Get a reference to the element type of this vector type. -/
@[extern "papyrus_vector_type_get_element_type"]
constant getElementType (self : @& VectorTypeRef) : IO TypeRef

/--
  Get the minimum number of elements of this vector type.
  For non-scalable vectors, this is exactly this number of elements.
  For scalable vectors, there is a runtime multiple of this number.
-/
@[extern "papyrus_vector_type_get_element_quantity"]
constant getMinSize (self : @& VectorTypeRef) : IO UInt32

/-- Get whether this vector type is scalable. -/
@[extern "papyrus_vector_type_is_scalable"]
constant isScalable (self : @& VectorTypeRef) : IO Bool

end VectorTypeRef

-- # Fixed Vector Types

/--
  A reference to an external LLVM
  [FixedVectorType](https://llvm.org/doxygen/classllvm_1_1FixedVectorType.html).
-/
def FixedVectorTypeRef := VectorTypeRef

namespace FixedVectorTypeRef

/--
  Get a reference to the fixed LLVM vector type of
    the given element type and number of elements.
  It is the user's responsibility to ensure they are valid.
-/
def  get (elemType : TypeRef) (numElems : UInt32) :=
  VectorTypeRef.get elemType numElems false

/-- Get the number of elements in this vector type. -/
def getSize (self : @& FixedVectorTypeRef) :=
  VectorTypeRef.getMinSize self

end FixedVectorTypeRef

-- # Scalable Vector Types

/--
  A reference to an external LLVM
  [ScalableVectorType](https://llvm.org/doxygen/classllvm_1_1ScalableVectorType.html).
-/
def ScalableVectorTypeRef := VectorTypeRef

namespace ScalableVectorTypeRef

/--
  Get a reference to the scalable LLVM vector type of
    the given element type and minimum number of elements.
  It is the user's responsibility to ensure they are valid.
-/
def  get (elemType : TypeRef) (minNumElems : UInt32) :=
  VectorTypeRef.get elemType minNumElems true

end ScalableVectorTypeRef
