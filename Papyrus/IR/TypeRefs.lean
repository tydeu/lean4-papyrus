import Papyrus.Context
import Papyrus.IR.TypeRef
import Papyrus.IR.AddressSpace

namespace Papyrus

--------------------------------------------------------------------------------
-- Singleton Type References
--------------------------------------------------------------------------------

-- # Special Types

/-- A reference to an external LLVM `void` type. -/
structure VoidTypeRef extends TypeRef where
  is_void_type : toTypeRef.typeID = TypeID.void

instance : Coe VoidTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `void` type of the current context. -/
@[extern "papyrus_get_void_type"]
constant VoidTypeRef.get : LlvmM VoidTypeRef

/-- A reference to an external LLVM `label` type. -/
structure LabelTypeRef extends TypeRef where
  is_label_type : toTypeRef.typeID = TypeID.void

instance : Coe LabelTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `label` type of the current context. -/
@[extern "papyrus_get_label_type"]
constant LabelTypeRef.get : LlvmM LabelTypeRef

/-- A reference to an external LLVM `metadata` type. -/
structure MetadataTypeRef extends TypeRef where
  is_metadata_type : toTypeRef.typeID = TypeID.metadata

instance : Coe MetadataTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `metadata` type of the current context. -/
@[extern "papyrus_get_metadata_type"]
constant MetadataTypeRef.get : LlvmM MetadataTypeRef

/-- A reference to an external LLVM `token` type. -/
structure TokenTypeRef extends TypeRef where
  is_token_type : toTypeRef.typeID = TypeID.token

instance : Coe TokenTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `token` type of the current context. -/
@[extern "papyrus_get_token_type"]
constant TokenTypeRef.get : LlvmM TokenTypeRef

/--
  A reference to an external LLVM `x86_mmx` type,
  which is a 64-bit X86 MMX vector type.
-/
structure X86MMXTypeRef extends TypeRef where
  is_x86MMX_type : toTypeRef.typeID = TypeID.x86MMX

instance : Coe X86MMXTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `x86_mmx` type of the current context. -/
@[extern "papyrus_get_x86_mmx_type"]
constant X86MMXTypeRef.get : LlvmM X86MMXTypeRef

/--
  A reference to an external LLVM `x86_mmx` type,
  which is a 8192-bit X86 AMX vector type.
-/
structure X86AMXTypeRef extends TypeRef where
  is_x86AMX_type : toTypeRef.typeID = TypeID.x86AMX

instance : Coe X86AMXTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `x86_mmx` type of the current context. -/
@[extern "papyrus_get_x86_amx_type"]
constant X86AMXTypeRef.get : LlvmM X86AMXTypeRef

-- # Floating Point Types

/--
  A reference to an external LLVM `half` type,
   which is an IEEE half-precision (16-bit) floating point type.
-/
structure HalfTypeRef extends TypeRef where
  is_half_type : toTypeRef.typeID = TypeID.half

instance : Coe HalfTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `half` type of the current context. -/
@[extern "papyrus_get_half_type"]
constant HalfTypeRef.get : LlvmM HalfTypeRef

/--
  A reference to an external LLVM `bfloat` type,
  which is a brain floating point type (16-bits with a 7-bit significand).
-/
structure BFloatTypeRef extends TypeRef where
  is_bfloat_type : toTypeRef.typeID = TypeID.bfloat

instance : Coe BFloatTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `bfloat` type of the current context. -/
@[extern "papyrus_get_bfloat_type"]
constant BFloatTypeRef.get : LlvmM BFloatTypeRef

/--
  A reference to an external LLVM `float` type,
  which is an IEEE single-precision (32-bit) floating point type.
-/
structure FloatTypeRef extends TypeRef where
  is_float_type : toTypeRef.typeID = TypeID.float

instance : Coe FloatTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `float` type of the current context. -/
@[extern "papyrus_get_float_type"]
constant FloatTypeRef.get : LlvmM FloatTypeRef

/--
  A reference to an external LLVM `float` type,
  which is an IEEE double-precision (64-bit) floating point type.
-/
structure DoubleTypeRef extends TypeRef where
  is_double_type : toTypeRef.typeID = TypeID.double

instance : Coe DoubleTypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `double` type of the current context. -/
@[extern "papyrus_get_double_type"]
constant DoubleTypeRef.get : LlvmM DoubleTypeRef

/--
  A reference to an external LLVM `x86_fp80` type,
  which is an Intel X87 80-bit floating point type.
-/
structure X86FP80TypeRef extends TypeRef where
  is_x86FP80_type : toTypeRef.typeID = TypeID.x86FP80

instance : Coe X86FP80TypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `x86_fp80` type of the current context. -/
@[extern "papyrus_get_x86_fp80_type"]
constant X86FP80TypeRef.get : LlvmM X86FP80TypeRef

/--
  A reference to an external LLVM `fp128` type,
  which is an IEEE quadruple-precision (128-bit) floating point type.
-/
structure FP128TypeRef extends TypeRef where
  is_fp128_type : toTypeRef.typeID = TypeID.fp128

instance : Coe FP128TypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `fp128` type of the current context. -/
@[extern "papyrus_get_fp128_type"]
constant FP128TypeRef.get : LlvmM FP128TypeRef

/--
  A reference to an external LLVM `ppc_fp128` type,
  which is a PowerPC 128-bit floating point type.
-/
structure PPCFP128TypeRef extends TypeRef where
  is_ppcFP128_type : toTypeRef.typeID = TypeID.ppcFP128

instance : Coe PPCFP128TypeRef TypeRef := ⟨(·.toTypeRef)⟩

/-- Get a reference to the `ppc_fp128` type of the current context. -/
@[extern "papyrus_get_ppc_fp128_type"]
constant PPCFP128TypeRef.get : LlvmM PPCFP128TypeRef

--------------------------------------------------------------------------------
-- Integer Type References
--------------------------------------------------------------------------------

/--
  A reference to an external LLVM
  [IntegerType](https://llvm.org/doxygen/classllvm_1_1IntegerType.html).
-/
structure IntegerTypeRef extends TypeRef where
  is_integer_type : toTypeRef.typeID = TypeID.integer

instance : Coe IntegerTypeRef TypeRef := ⟨(·.toTypeRef)⟩

namespace IntegerTypeRef

/-- Cast a general `TypeRef` to a `IntegerTypeRef` given proof it is one. -/
def cast (type : TypeRef) (h : type.typeID = TypeID.integer) := mk type h

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
constant get (numBits : @& UInt32) : LlvmM IntegerTypeRef

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
structure FunctionTypeRef extends TypeRef where
  is_function_type : toTypeRef.typeID = TypeID.function

instance : Coe FunctionTypeRef TypeRef := ⟨(·.toTypeRef)⟩

namespace FunctionTypeRef

/-- Cast a general `TypeRef` to a `FunctionTypeRef` given proof it is one. -/
def cast (type : TypeRef) (h : type.typeID = TypeID.function) : FunctionTypeRef :=
  {toTypeRef := type, is_function_type := h}

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
structure PointerTypeRef extends TypeRef where
  is_pointer_type : toTypeRef.typeID = TypeID.pointer

instance : Coe PointerTypeRef TypeRef := ⟨(·.toTypeRef)⟩

namespace PointerTypeRef

/-- Cast a general `TypeRef` to a `FunctionTypeRef` given proof it is one. -/
def cast (type : TypeRef) (h : type.typeID = TypeID.pointer) := mk type h

/--
  Get a reference to the LLVM pointer type of
    the given pointee type in the given address space.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_pointer_type"]
constant get (pointeeType : @& TypeRef) (addrSpace := AddressSpace.default)
  : IO PointerTypeRef

/-- Get a reference to the type pointed to by this type. -/
@[extern "papyrus_pointer_type_get_pointee_type"]
constant getPointeeType (self : @& PointerTypeRef) : IO TypeRef

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
structure StructTypeRef extends TypeRef where
  is_struct_type : toTypeRef.typeID = TypeID.struct

instance : Coe StructTypeRef TypeRef := ⟨(·.toTypeRef)⟩

namespace StructTypeRef

/-- Cast a general `TypeRef` to a `StructTypeRef` given proof it is one. -/
def cast (type : TypeRef) (h : type.typeID = TypeID.struct) := mk type h

/-- Get whether this struct type is literal. -/
@[extern "papyrus_struct_type_is_literal"]
constant isLiteral (self : @& StructTypeRef) : Bool

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
structure LiteralStructTypeRef extends StructTypeRef where
  is_literal : toStructTypeRef.isLiteral = true

instance : Coe LiteralStructTypeRef StructTypeRef := ⟨(·.toStructTypeRef)⟩

namespace LiteralStructTypeRef

/-- Cast a general `StructTypeRef` to a `LiteralStructTypeRef` given proof it is one. -/
def cast (type : StructTypeRef) (h : type.isLiteral = true) := mk type h

/--
  Get a reference to the LLVM literal struct type of
    with the given element types and packing.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_literal_struct_type"]
constant get (elemTypes : @& Array TypeRef) (isPacked := false)
  : LlvmM LiteralStructTypeRef

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
structure IdentifiedStructTypeRef extends StructTypeRef where
  is_identified : toStructTypeRef.isLiteral ≠ true

instance : Coe IdentifiedStructTypeRef StructTypeRef := ⟨(·.toStructTypeRef)⟩

namespace IdentifiedStructTypeRef

/-- Cast a general `StructTypeRef` to a `IdentifiedStructTypeRef` given proof it is one. -/
def cast (type : StructTypeRef) (h : type.isLiteral ≠ true) := mk type h

/-- Get the struct type with the given name (if it exists). -/
@[extern "papyrus_struct_type_get_type_by_name"]
constant getTypeByName? (name : String) : LlvmM (Option IdentifiedStructTypeRef)

/--
  Create a new struct type
    with the given name, element types, and packing.
  It is the user's responsibility to ensure they are valid.
  Passing the empty name string will leave the type unnamed.
-/
@[extern "papyrus_struct_type_create"]
constant create (name : @& String) (elementTypes : @& Array TypeRef)
  (packed := false) : LlvmM IdentifiedStructTypeRef

/--
  Get the struct type with the given name or create one if none exists.
  If one exists, it will *NOT* be verified to have the provided structure.
-/
def getOrCreate (name : String)
(elementTypes : @& Array TypeRef) (packed := false)
: LlvmM IdentifiedStructTypeRef := do
  match (← getTypeByName? name) with
  | none => create name elementTypes packed
  | some ty => ty

/--
  Create a new opaque struct type with the given name
  (or none if the name string is empty).
-/
@[extern "papyrus_opaque_struct_type_create"]
constant createOpaque (name : @& String) : LlvmM IdentifiedStructTypeRef

/--
  Get the struct type with the given name or create a new opaque one if none exists.
  If one exists, it will *NOT* be verified to be opaque.
-/
def getOrCreateOpaque (name : String) : LlvmM IdentifiedStructTypeRef := do
  match (← getTypeByName? name) with
  | none => createOpaque name
  | some ty => ty


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
structure ArrayTypeRef extends TypeRef where
  is_array_type : toTypeRef.typeID = TypeID.array

instance : Coe ArrayTypeRef TypeRef := ⟨(·.toTypeRef)⟩

namespace ArrayTypeRef

/-- Cast a general `TypeRef` to a `ArrayTypeRef` given proof it is one. -/
def cast (type : TypeRef) (h : type.typeID = TypeID.array) := mk type h

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
structure VectorTypeRef extends TypeRef where
  is_vector_type :
    toTypeRef.typeID = TypeID.fixedVector ∨
    toTypeRef.typeID = TypeID.scalableVector

instance : Coe VectorTypeRef TypeRef := ⟨(·.toTypeRef)⟩

namespace VectorTypeRef

/-- Cast a general `TypeRef` to a `VectorTypeRef` given proof it is one. -/
def cast (type : TypeRef) (h) := mk type h

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
def isScalable (self : @& VectorTypeRef) : Bool :=
  self.typeID = TypeID.scalableVector

end VectorTypeRef


-- # Fixed Vector Types

/--
  A reference to an external LLVM
  [FixedVectorType](https://llvm.org/doxygen/classllvm_1_1FixedVectorType.html).
-/
structure FixedVectorTypeRef extends VectorTypeRef where
  is_fixed_vector_type : toTypeRef.typeID = TypeID.fixedVector
  is_vector_type := Or.inl is_fixed_vector_type

instance : Coe FixedVectorTypeRef VectorTypeRef := ⟨(·.toVectorTypeRef)⟩

namespace FixedVectorTypeRef

/-- Cast a general `TypeRef` to a `FixedVectorTypeRef` given proof it is one. -/
def cast (type : TypeRef) (h : type.typeID = TypeID.fixedVector) : FixedVectorTypeRef :=
  {toTypeRef := type, is_fixed_vector_type := h}

/--
  Get a reference to the fixed LLVM vector type of
    the given element type and number of elements.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_fixed_vector_type"]
constant get (elemType : TypeRef) (numElems : UInt32) : IO FixedVectorTypeRef

/-- Get the number of elements in this vector type. -/
def getSize (self : @& FixedVectorTypeRef) :=
  VectorTypeRef.getMinSize self

end FixedVectorTypeRef

-- # Scalable Vector Types

/--
  A reference to an external LLVM
  [ScalableVectorType](https://llvm.org/doxygen/classllvm_1_1ScalableVectorType.html).
-/
structure ScalableVectorTypeRef extends VectorTypeRef where
  is_scalable_vector_type : toTypeRef.typeID = TypeID.scalableVector
  is_vector_type := Or.inr is_scalable_vector_type

instance : Coe ScalableVectorTypeRef VectorTypeRef := ⟨(·.toVectorTypeRef)⟩

namespace ScalableVectorTypeRef

/-- Cast a general `TypeRef` to a `ScalableVectorTypeRef` given proof it is one. -/
def cast (type : TypeRef) (h : type.typeID = TypeID.scalableVector) : ScalableVectorTypeRef :=
  {toTypeRef := type, is_scalable_vector_type := h}

/--
  Get a reference to the scalable LLVM vector type of
    the given element type and minimum number of elements.
  It is the user's responsibility to ensure they are valid.
-/
@[extern "papyrus_get_scalable_vector_type"]
constant get (elemType : TypeRef) (minNumElems : UInt32) : IO ScalableVectorTypeRef

end ScalableVectorTypeRef

namespace VectorTypeRef

/--
  Get a reference to the LLVM vector type of
    the given element type, element quantity, and scalability.
  It is the user's responsibility to ensure they are valid.
-/
def get (elemType : @& TypeRef) (elemQuant : UInt32) (isScalable := false) : IO VectorTypeRef :=
  if isScalable then
    ScalableVectorTypeRef.get elemType elemQuant
  else
    FixedVectorTypeRef.get elemType elemQuant

end VectorTypeRef
