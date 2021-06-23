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

@[extern "papyrus_get_integer_type"]
private constant getIntegerTypeRef (numBits : @& UInt32) : LLVM TypeRef

-- Minimum number of bits that can be specified.
def IntegerType.MIN_INT_BITS : Nat := 1

-- Maximum number of bits that can be specified.
def IntegerType.MAX_INT_BITS : Nat := 16777215 -- (1 <<< 24) - 1

structure IntegerType where
  /-- The number of bits in this type. -/
  bitWidth : UInt32
  isGt : bitWidth.toNat >= IntegerType.MIN_INT_BITS
  isLt : bitWidth.toNat <= IntegerType.MAX_INT_BITS

/-- Create a new IntegerType, attempting to auto prove hypotheses by decide. -/
def integerType
  (bitWidth : UInt32)
  (isGt : bitWidth.toNat >= IntegerType.MIN_INT_BITS := by decide)
  (isLt : bitWidth.toNat <= IntegerType.MAX_INT_BITS := by decide)
:=
  IntegerType.mk bitWidth isGt isLt

namespace IntegerType

/-- Make a new IntegerType, attempting to auto prove hypotheses by decide. -/
def mk'
  (bitWidth : UInt32)
  (isGt : bitWidth.toNat >= IntegerType.MIN_INT_BITS := by decide)
  (isLt : bitWidth.toNat <= IntegerType.MAX_INT_BITS := by decide)
:=
  mk bitWidth isGt isLt

/-- Get a reference to the LLVM representation of this type. -/
def getRef (self : IntegerType) : LLVM TypeRef :=
  getIntegerTypeRef self.bitWidth

/--
  A UInt64 bit mask with ones set for all the bits of this type
  (or just every bit, if this type's bit width is greater than 64).
-/
def bitMask (self : IntegerType) : UInt64 :=
  ~~~(0 : UInt64) >>> (64 - self.bitWidth.toUInt64)

/--
  Returns a UInt64 with just the most significant bit of this type set
  (the sign bit, if the value is treated as a signed number).
-/
def signBit (self : IntegerType) : UInt64 :=
  (1 : UInt64) <<< (self.bitWidth.toUInt64 - 1)

/--
  A bit mask with ones set for all the bits of this type.
  For example, this is 0xFF for an 8 bit integer, 0xFFFF for i16, etc.
-/
def mask (self : IntegerType) : Nat :=
  (1 <<< self.bitWidth.toNat) - 1

end IntegerType

instance : ToTypeRef IntegerType := ⟨IntegerType.getRef⟩

--------------------------------------------------------------------------------
-- Pointer Types
--------------------------------------------------------------------------------

@[extern "papyrus_get_pointer_type"]
private constant getPointerTypeRef (pointee : TypeRef) (addrSpace : @& UInt32) : LLVM TypeRef

/-- A numerically indexed address space. -/
structure AddressSpace where
  index : UInt32

/-- The default address space (i.e., 0). -/
def AddressSpace.default :=
  AddressSpace.mk 0

instance : Inhabited AddressSpace := ⟨AddressSpace.default⟩

def AddressSpace.ofNat (n : Nat) :=
  AddressSpace.mk (UInt32.ofNat n)

instance {n} : OfNat AddressSpace n := ⟨AddressSpace.ofNat n⟩

/-- A type for pointers to a given set of types. -/
structure PointerType (α) where
  pointeeType : α
  addressSpace := AddressSpace.default

/--
  Create a new pointer type to the given type in the given address space
  (or the default one).
-/
def pointerType (pointeeType : α) (addrSpace := AddressSpace.default) :=
  PointerType.mk pointeeType addrSpace

namespace PointerType

/-- Make a new pointer type to the given type in the default address space. -/
def mk' (pointeeType : α) :=
  PointerType.mk pointeeType AddressSpace.default

/-- Get a reference to the LLVM representation of this type. -/
def getRef [ToTypeRef α] (self : PointerType α) : LLVM TypeRef := do
  getPointerTypeRef (← toTypeRef self.pointeeType) self.addressSpace.index

end PointerType

instance [ToTypeRef α] : ToTypeRef (PointerType α) := ⟨PointerType.getRef⟩

-- Conveince methods for constructing pointer types
def HalfType.pointer (self : HalfType) := pointerType self
def FloatType.pointer (self : FloatType) := pointerType self
def DoubleType.pointer (self : DoubleType) := pointerType self
def IntegerType.pointer (self : DoubleType) := pointerType self
def PointerType.pointer (self : DoubleType) := pointerType self
