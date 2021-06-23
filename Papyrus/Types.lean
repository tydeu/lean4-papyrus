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
-- Special Types
--------------------------------------------------------------------------------

/-- An empty type. -/
structure VoidType deriving Inhabited

/-- The vold type singleton. -/
def voidType : VoidType := arbitrary

@[extern "papyrus_get_void_type"]
private constant getVoidTypeRef : LLVM TypeRef

/-- Get a reference to the LLVM representation of this type. -/
def VoidType.getRef (_self : VoidType) := getVoidTypeRef

instance : ToTypeRef VoidType := ⟨VoidType.getRef⟩

/-- A label type. -/
structure LabelType deriving Inhabited

/-- The label type singleton. -/
def labelType : LabelType := arbitrary

@[extern "papyrus_get_label_type"]
private constant getLabelTypeRef : LLVM TypeRef

/-- Get a reference to the LLVM representation of this type. -/
def LabelType.getRef (_self : LabelType) := getLabelTypeRef

instance : ToTypeRef LabelType := ⟨LabelType.getRef⟩

/-- A metadata type. -/
structure MetadataType deriving Inhabited

/-- The metadata type singleton. -/
def metadataType : MetadataType := arbitrary

@[extern "papyrus_get_metadata_type"]
private constant getMetadataTypeRef : LLVM TypeRef

/-- Get a reference to the LLVM representation of this type. -/
def MetadataType.getRef (_self : MetadataType) := getMetadataTypeRef

instance : ToTypeRef MetadataType := ⟨MetadataType.getRef⟩

/-- A token type. -/
structure TokenType deriving Inhabited

/-- The token type singleton. -/
def tokenType : TokenType := arbitrary

@[extern "papyrus_get_token_type"]
private constant getTokenTypeRef : LLVM TypeRef

/-- Get a reference to the LLVM representation of this type. -/
def TokenType.getRef (_self : TokenType) := getTokenTypeRef

instance : ToTypeRef TokenType := ⟨TokenType.getRef⟩

/-- An 64-bit X86 MMX vector type. -/
structure X86MMXType deriving Inhabited

/-- The X86 MMX type singleton. -/
def x86MMXType : X86MMXType := arbitrary

@[extern "papyrus_get_x86_mmx_type"]
private constant getX86MMXTypeRef : LLVM TypeRef

/-- Get a reference to the LLVM representation of this type. -/
def X86MMXType.getRef (_self : X86MMXType) := getX86MMXTypeRef

instance : ToTypeRef X86MMXType := ⟨X86MMXType.getRef⟩

--------------------------------------------------------------------------------
-- Floating Point Types
--------------------------------------------------------------------------------

/-- A 16-bit floating point type. -/
structure HalfType deriving Inhabited

/-- The half type singleton. -/
def halfType : HalfType := arbitrary

@[extern "papyrus_get_half_type"]
private constant getHalfTypeRef : LLVM TypeRef

/-- Get a reference to the LLVM representation of this type. -/
def HalfType.getRef (_self : HalfType) := getHalfTypeRef

instance : ToTypeRef HalfType := ⟨HalfType.getRef⟩

/-- A 32-bit floating point type. -/
structure FloatType deriving Inhabited

/-- The float type singleton. -/
def floatType : FloatType := arbitrary

@[extern "papyrus_get_float_type"]
private constant getFloatTypeRef : LLVM TypeRef

/-- Get a reference to the LLVM representation of this type. -/
def FloatType.getRef (_self : FloatType) := getFloatTypeRef

instance : ToTypeRef FloatType := ⟨FloatType.getRef⟩

/-- The 64-bit floating point type. -/
structure DoubleType deriving Inhabited

/-- The double type singleton. -/
def doubleType : DoubleType := arbitrary

@[extern "papyrus_get_double_type"]
private constant getDoubleTypeRef : LLVM TypeRef

/-- Get a reference to the LLVM representation of this type. -/
def DoubleType.getRef (_self : DoubleType) := getDoubleTypeRef

instance : ToTypeRef DoubleType := ⟨DoubleType.getRef⟩

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
