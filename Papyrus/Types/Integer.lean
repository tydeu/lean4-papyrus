import Papyrus.Types.TypeRef

namespace Papyrus

/-- An arbirtrary precision integer type. -/
structure IntegerType (numBits : Nat) deriving Inhabited

/-- An integer type of the given precision. -/
def integerType (numBits : Nat) : IntegerType numBits :=
  IntegerType.mk

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
