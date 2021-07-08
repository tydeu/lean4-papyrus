import Papyrus.IR.TypeID
import Papyrus.IR.AddressSpace

namespace Papyrus

--------------------------------------------------------------------------------
-- # IntegerType
--------------------------------------------------------------------------------

/--
  A pure representation of an LLVM
  [IntegerType](https://llvm.org/doxygen/classllvm_1_1IntegerType.html).
-/
structure IntegerType where
  /-- The width in bits of integers of this type. -/
  bitWidth : UInt32
  deriving BEq, Repr

/-- An integer type of the given precision. -/
def integerType (numBits : UInt32) : IntegerType :=
  IntegerType.mk numBits

namespace IntegerType

/-- The type ID of an integer type (i.e., `integer`). -/
def typeID (self : IntegerType) := TypeID.integer

/-- An integer type twice as wide as this type. -/
def extendedType (self : IntegerType) :=
  integerType (self.bitWidth <<< 1)

/--
  A 64-bit mask with ones set for all the bits of this type
  (or just every bit, if this type's bit width is greater than 64).
-/
def bitMask (self : IntegerType) : UInt64 :=
  ~~~(0 : UInt64) >>> (64 - self.bitWidth.toUInt64)

/--
  A `UInt64` with just the most significant bit of this type set
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

-- ## Specializations

/-- A 1-bit integer type (e.g., a `bool`). -/
abbrev int1Type := integerType 1

/-- An 8-bit integer type (e.g., a `byte` or `char`). -/
abbrev int8Type := integerType 8

/-- A 16-bit integer type (e.g., a `short`). -/
abbrev int16Type := integerType 16

/-- A 32-bit integer type (e.g., a `long`). -/
abbrev int32Type := integerType 32

/-- A 64-bit integer type (e.g., a `long long`). -/
abbrev int64Type := integerType 64

/-- A 128-bit integer type. -/
abbrev int128Type := integerType 128

--------------------------------------------------------------------------------
-- # BaseFunctionType
--------------------------------------------------------------------------------

/-- Base type of `FunctionType`. Used to avoid mutual recursion with `Type`. -/
structure BaseFunctionType (t) where
  /-- The type of return values of functions of this type. -/
  returnType : t
  /-- The types of parameters of functions of this type. -/
  parameterTypes : Array t
  /-- Do functions of this type accept a variable number of arguments (e.g., `printf`). -/
  isVarArg := false
  deriving BEq, Repr

/-- The type ID of a function type (i.e., `function`). -/
def BaseFunctionType.typeID (self : BaseFunctionType t) := TypeID.function

--------------------------------------------------------------------------------
-- # BasePointerType
--------------------------------------------------------------------------------

/-- Base type of `PointerType`. Used to avoid mutual recursion with `Type`. -/
structure BasePointerType.{u} (t : Type u) where
  /-- The type pointed to by pointers of this type. -/
  pointeeType : t
  /-- The address space pointers of this type belongs to. -/
  addressSpace := AddressSpace.default
  deriving BEq, Repr

/-- The type ID of a pointer type (i.e., `pointer`). -/
def BasePointerType.typeID (self : BasePointerType t) := TypeID.pointer

--------------------------------------------------------------------------------
-- # BaseStructType
--------------------------------------------------------------------------------

/-- Base type of `StructTypeBody`. Used to avoid mutual recursion with `Type`. -/
structure BaseStructTypeBody (t) where
  /-- The types of the elements of structs of this type. -/
  elementTypes : Array t
  /--
    If true, structs of this type are packed
    (i.e., no padding of elements is allowed).
  -/
  isPacked : Bool
  deriving BEq, Repr

/-- Base type of `StructType`. Used to avoid mutual recursion with `Type`. -/
inductive BaseStructType (t)
| literal (body : BaseStructTypeBody t)
| identified (name : String) (body? : Option (BaseStructTypeBody t))
deriving BEq, Repr

namespace BaseStructType

@[matchPattern]
def opaque (name : String) : BaseStructType t :=
  identified name none

@[matchPattern]
def complete (name : String) (body : BaseStructTypeBody t): BaseStructType t :=
  identified name (some body)

/-- The type ID of a struct type (i.e., `struct`). -/
def typeID (self : BaseStructType t) := TypeID.struct

/-- Is the struct type is literal? -/
def isLiteral : (self : BaseStructType t) → Bool
| literal _ => true
| _ => false

/-- Does this struct type have a non-empty name. -/
def hasName : (self : BaseStructType t) → Bool
| literal _ => false
| identified name _ => name.bsize != 0

/-- The name of this string (or the empty string if literal). -/
def name : (self : BaseStructType t) → String
| literal _ => ""
| identified name _ => name

/-- The name of this string (or none if literal). -/
def name? : (self : BaseStructType t) → Option String
| literal _ => none
| identified name _ => some name

/-- Change/set the name of the struct type. -/
def withName (name : String)
: (self : BaseStructType t) → BaseStructType t
| literal body => identified name body
| identified _ body? => identified name body?

/-- Is the struct type is opaque? -/
def isOpaque : (self : BaseStructType t) → Bool
| opaque _  => true
| _ => false

/-- Does this struct type have a body (i.e., is it not opaque)? -/
def hasBody : (self : BaseStructType t) → Bool
| opaque _ => false
| _ => true

/-- The body of the struct (or none if opaque). -/
def body? : (self : BaseStructType t) → Option (BaseStructTypeBody t)
| literal body => some body
| identified _ body? => body?

/-- Change/set the body of the struct type. -/
def withBody (body : BaseStructTypeBody t)
: (self : BaseStructType t) → BaseStructType t
| literal _ => literal body
| identified name _ => identified name (some body)

/-- The element types of the struct (or the empty array if opaque). -/
def elementTypes : (self : BaseStructType t) → Array t
| literal body => body.elementTypes
| complete _ body => body.elementTypes
| opaque _ => #[]

/-- The element types of the struct (if they are defined). -/
def elementTypes? : (self : BaseStructType t) → Option (Array t)
| literal body => some body.elementTypes
| identified _ body? => body?.map (·.elementTypes)

/-- Is the struct type is non-opaque and packed? -/
def isPacked : (self : BaseStructType t) → Bool
| literal ⟨_, packed⟩ => packed
| complete _ ⟨_, packed⟩ => packed
| opaque _ => false

end BaseStructType

--------------------------------------------------------------------------------
-- # BaseArrayType
--------------------------------------------------------------------------------

/-- Base type of `ArrayType`. Used to avoid mutual recursion with `Type`. -/
structure BaseArrayType.{u} (t : Type u) where
  /-- The type of elements of arrays of this type. -/
  elementType : t
  /-- The size of arrays of this type. -/
  size : UInt64
  deriving BEq, Repr

/-- The type ID of an array type (i.e., `array`). -/
def BaseArrayType.typeID (self : BaseArrayType t) := TypeID.array

--------------------------------------------------------------------------------
-- # Base Vector Types
--------------------------------------------------------------------------------

-- ## Abstract Base

/-- The abstract parent of both fixed-length and scalable SIMD vector types. -/
structure BaseAbstractVectorType.{u} (t : Type u) where
  /-- The type of elements of vectors of this type. -/
  elementType : t
  /-- The minimum size of vectors of this type. -/
  minSize : UInt32
  deriving BEq, Repr

-- ## BaseVectorType

/-- Base type of `VectorType`. Used to avoid mutual recursion with `Type`. -/
structure BaseVectorType (t) extends BaseAbstractVectorType t where
  isScalable : Bool
  deriving BEq, Repr

/-- The type ID of this SIMD vector type (i.e., `fixedVector` or `scalableVector`). -/
def BaseVectorType.typeID (self : BaseVectorType t) :=
  if self.isScalable then TypeID.scalableVector else TypeID.fixedVector

-- ## BaseFixedVectorType

/-- Base type of `FixedVectorType`. Used to avoid mutual recursion with `Type`. -/
structure BaseFixedVectorType (t) extends BaseAbstractVectorType t
  deriving BEq, Repr

instance : Coe (BaseFixedVectorType t) (BaseVectorType t) where
  coe v := ⟨v.toBaseAbstractVectorType, false⟩

/-- The type ID of a fixed-length SIMD vector type (i.e., `fixedVector`). -/
def BaseFixedVectorType.typeID (self : BaseFixedVectorType t) := TypeID.fixedVector

/-- The size of this vector (i.e., exactly its `minSize`). -/
def BaseFixedVectorType.size (self : BaseFixedVectorType t) := self.minSize

-- ## BaseScalableVectorType

/-- Base type of `ScalableVectorType`. Used to avoid mutual recursion with `Type`. -/
structure BaseScalableVectorType (t) extends BaseAbstractVectorType t
  deriving BEq, Repr

instance : Coe (BaseScalableVectorType t) (BaseVectorType t) where
  coe v := ⟨v.toBaseAbstractVectorType, true⟩

/-- The type ID of an scalable SIMD vector type (i.e., `scalableVector`). -/
def BaseScalableVectorType.typeID (self : BaseScalableVectorType t) :=
  TypeID.scalableVector
