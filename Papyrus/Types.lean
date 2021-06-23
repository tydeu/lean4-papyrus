import Lean.Parser
import Papyrus.Context

namespace Papyrus

--------------------------------------------------------------------------------
-- Type IDs
--------------------------------------------------------------------------------

/-- Identifiers for all of the base types of the LLVM type system. -/
inductive TypeID
-- Primitive types
| /-- 16-bit floating point type -/
  Half
| /-- 16-bit floating point type (7-bit significand) -/
  BFloat
| /-- 32-bit floating point type -/
  Float
| /-- 64-bit floating point type -/
  Double
| /-- 80-bit floating point type (X87) -/
  X86_FP80
| /-- 128-bit floating point type (112-bit significand) -/
  FP128
| /-- 128-bit floating point type -/
  PPC_FP128
| /-- type with no size -/
  Void
| Label
| Metadata
| /-- MMX vectors (64 bits, X86 specific) -/
  X86_MMX
| Token
-- Derived types
| /-- Arbitrary bit width integers -/
  Integer
| Function
| Pointer
| Struct
| Array
| /-- Fixed width SIMD vector type -/
  FixedVector
| /-- Scalable SIMD vector type -/
  ScalableVector
deriving BEq, Repr

--------------------------------------------------------------------------------
-- Type References
--------------------------------------------------------------------------------

/-- A reference to the LLVM representation of a Type. -/
constant TypeRef : Type := Unit

namespace TypeRef

/-- Get the `TypeID` of this type. -/
@[extern "papyrus_type_get_id"]
constant getTypeID (self : TypeRef) : IO TypeID

/-- Get the owning LLVM context of this type. -/
@[extern "papyrus_type_get_context"]
constant getContext (self : TypeRef) : IO ContextRef

end TypeRef

/-- General class for retrieving LLVM type representations. -/
class ToTypeRef (α) where
  toTypeRef : α → LLVM TypeRef

export ToTypeRef (toTypeRef)

--------------------------------------------------------------------------------
-- Primitive Types
--------------------------------------------------------------------------------

open Lean Parser Command in set_option hygiene false in
/-- Macro for creating singleton Lean types for primitive LLVM types. -/
scoped macro (name := externSingletonTypeDecl) doc:docComment
"extern_singleton_type" impl:str typ:ident singl:ident : command => do
  let getGlobalRef := mkIdentFrom typ <|
    typ.getId.modifyBase fun name => s!"get{name.getRoot}Ref"
  let getRef := mkIdentFrom typ <| typ.getId.modifyBase (. ++ `getRef)
  `(
    $doc:docComment
    structure $typ deriving Inhabited

    $doc:docComment
    def $singl : $typ := arbitrary

    @[extern $impl:strLit]
    private constant $getGlobalRef : LLVM TypeRef

    /-- Get a reference to the LLVM representation of this type. -/
    def $getRef (_self : $typ) := $getGlobalRef

    instance : ToTypeRef $typ := ⟨$getRef⟩
  )

-- # Special Types

/-- An empty type. -/
extern_singleton_type "papyrus_get_void_type" VoidType voidType

/-- A label type. -/
extern_singleton_type "papyrus_get_label_type" LabelType labelType

/-- A metadata type. -/
extern_singleton_type "papyrus_get_metadata_type" MetadataType metadataType

/-- A token type. -/
extern_singleton_type "papyrus_get_token_type" TokenType tokenType

/-- A 64-bit X86 MMX vector type. -/
extern_singleton_type "papyrus_get_x86_mmx_type" X86MMXType x86MMXType

-- # Floating Point Types

/-- A 16-bit floating point type. -/
extern_singleton_type "papyrus_get_half_type" HalfType halfType

/-- A 16-bit (7-bit significand) floating point type. -/
extern_singleton_type "papyrus_get_bfloat_type" BFloatType bfloatType

/-- A 32-bit floating point type. -/
extern_singleton_type "papyrus_get_float_type" FloatType floatType

/-- A 64-bit floating point type. -/
extern_singleton_type "papyrus_get_double_type" DoubleType doubleType

/-- An X87 80-bit floating point type. -/
extern_singleton_type "papyrus_get_x86_fp80_type" X86FP80Type x86FP80Type

/-- A 128-bit (112-bit significand) floating point type. -/
extern_singleton_type "papyrus_get_fp128_type" FP128Type fp128Type

/-- A PowerPC 128-bit floating point type. -/
extern_singleton_type "papyrus_get_ppc_fp128_type" PPCFP128Type ppcFP128Type

--------------------------------------------------------------------------------
-- Integer Types
--------------------------------------------------------------------------------

/-- An arbirtrary precision integer type. -/
structure IntegerType (numBits : Nat) deriving Inhabited

/-- Make a new integer type with the given precision. -/
def IntegerType.mk' (numBits : Nat) : IntegerType numBits :=
  IntegerType.mk

/-- An integer type of the given precision. -/
def integerType (numBits : Nat) :=
  IntegerType.mk' numBits

@[extern "papyrus_get_integer_type"]
private constant getIntegerTypeRef (numBits : @& UInt32) : LLVM TypeRef

namespace IntegerType

/-- Minimum number of bits that can be specified. -/
def MIN_INT_BITS : Nat := 1

/-- Maximum number of bits that can be specified. -/
def MAX_INT_BITS : Nat := 16777215 -- (1 <<< 24) - 1

/-- Condition for a valid integer type. -/
def isValidBitWidth (bitWidth : Nat) : Prop :=
  bitWidth ≥ IntegerType.MIN_INT_BITS ∧ bitWidth ≤ IntegerType.MAX_INT_BITS

variable {numBits : Nat}

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsible to ensure that the bit width of the type falls
  within the LLVM's requirements (i.e., that `isValidBitWidth numBits` holds).
-/
def getRef (self : IntegerType numBits) : LLVM TypeRef :=
  getIntegerTypeRef numBits.toUInt32

/-- The number of bits in this type. -/
def bitWidth (self : IntegerType numBits) := numBits

/-- An integer type twice as wide as this type. -/
def extendedType (self : IntegerType numBits) :=
  integerType (self.bitWidth <<< 1)

/--
  A 64-bit mask with ones set for all the bits of this type
  (or just every bit, if this type's bit width is greater than 64).
-/
def bitMask (self : IntegerType numBits) : UInt64 :=
  ~~~(0 : UInt64) >>> (64 - self.bitWidth.toUInt64)

/--
  A `UInt64` with just the most significant bit of this type set
  (the sign bit, if the value is treated as a signed number).
-/
def signBit (self : IntegerType numBits) : UInt64 :=
  (1 : UInt64) <<< (self.bitWidth.toUInt64 - 1)

/--
  A bit mask with ones set for all the bits of this type.
  For example, this is 0xFF for an 8 bit integer, 0xFFFF for i16, etc.
-/
def mask (self : IntegerType numBits) : Nat :=
  (1 <<< self.bitWidth) - 1

end IntegerType

instance {numBits} : ToTypeRef (IntegerType numBits) := ⟨IntegerType.getRef⟩

--------------------------------------------------------------------------------
-- Pointer Types
--------------------------------------------------------------------------------

-- # Address Space

/-- A numerically indexed address space. -/
structure AddressSpace where
  index : Nat

namespace AddressSpace

/-- The default address space (i.e., 0). -/
def default := mk 0

/-- Make an address space from a `Nat`. -/
def ofNat (n : Nat) := mk n

end AddressSpace

instance : Inhabited AddressSpace := ⟨AddressSpace.default⟩
instance {n} : OfNat AddressSpace n := ⟨AddressSpace.ofNat n⟩

-- # Pointer Type

/-- A type for pointers to a given kind of types. -/
structure PointerType (α) (addrSpace := AddressSpace.default) where
  pointeeType : α

/--
  Make a new pointer type to the given type
  in the given address space (or the default one).
-/
def PointerType.mk' (pointeeType : α) (addrSpace := AddressSpace.default) :=
  (PointerType.mk pointeeType : PointerType α addrSpace)

/--
  A pointer type to the given type
  in the given address space (or the default one).
-/
def pointerType (pointeeType : α) (addrSpace := AddressSpace.default) :=
  PointerType.mk' pointeeType addrSpace

@[extern "papyrus_get_pointer_type"]
private constant getPointerTypeRef
  (pointeeType : @& TypeRef) (addrSpace : UInt32) : IO TypeRef

namespace PointerType
variable {addrSpace : AddressSpace}

/-- The address space of this pointer type. -/
def addressSpace (self : PointerType α addrSpace) := addrSpace

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the pointee type
    and address space are valid.
-/
def getRef [ToTypeRef α] (self : PointerType α addrSpace) : LLVM TypeRef := do
  getPointerTypeRef (← toTypeRef self.pointeeType) self.addressSpace.index.toUInt32

end PointerType

instance [ToTypeRef α] {addrSpace} : ToTypeRef (PointerType α addrSpace) :=
  ⟨PointerType.getRef⟩

--------------------------------------------------------------------------------
-- Array Types
--------------------------------------------------------------------------------

structure ArrayType (α) (numElems : Nat) where
  elementType : α

/-- Make a new array type of the given type and the given size. -/
def ArrayType.mk' (elementType : α) (numElems : Nat) : ArrayType α numElems :=
  ArrayType.mk elementType

/-- An array type of the given type and the given size. -/
def arrayType (elementType : α) (numElems : Nat) :=
  ArrayType.mk' elementType numElems

@[extern "papyrus_get_array_type"]
private constant getArrayTypeRef
  (elemType : @& TypeRef) (numElems : UInt64) : IO TypeRef

namespace ArrayType
variable {numElems : Nat}

/-- The number of elements in this type. -/
def size (self : ArrayType α numElems) := numElems

/--
  Get a reference to the LLVM representation of this type.
  It is the user's responsibility to ensure that the element type
  and size are valid.
-/
def getRef [ToTypeRef α] (self : ArrayType α numElems) : LLVM TypeRef := do
  getArrayTypeRef (← toTypeRef self.elementType) self.size.toUInt64

end ArrayType

instance [ToTypeRef α] {numElems} : ToTypeRef (ArrayType α numElems) :=
  ⟨ArrayType.getRef⟩

--------------------------------------------------------------------------------
-- Vector Types
--------------------------------------------------------------------------------

structure VectorType (α) (elementQuantity : Nat) where
  elementType : α

@[extern "papyrus_get_fixed_vector_type"]
private constant getFixedVectorTypeRef
  (elemType : @& TypeRef) (numElems : UInt32) : IO TypeRef

@[extern "papyrus_get_scalable_vector_type"]
private constant getScalableVectorTypeRef
  (elemType : @& TypeRef) (minNumElems : UInt32) : IO TypeRef

--------------------------------------------------------------------------------
-- Convience Methods
--------------------------------------------------------------------------------

-- # Pointer Types

def HalfType.pointerType (self : HalfType) := PointerType.mk' self
def BFloatType.pointerType (self : BFloatType) := PointerType.mk' self
def FloatType.pointerType (self : FloatType) := PointerType.mk' self
def DoubleType.pointerType (self : DoubleType) := PointerType.mk' self
def X86FP80Type.pointerType (self : X86FP80Type) := PointerType.mk' self
def FP128Type.pointerType (self : FP128Type) := PointerType.mk' self
def PPCFP128Type.pointerType (self : PPCFP128Type) := PointerType.mk' self

def IntegerType.pointerType {numBits} (self : IntegerType numBits) :=
  PointerType.mk' self
def PointerType.pointerType {addrSpace} (self : PointerType α addrSpace) :=
  PointerType.mk' self
def ArrayType.pointerType {numElems} (self : ArrayType α numElems) :=
  PointerType.mk' self
