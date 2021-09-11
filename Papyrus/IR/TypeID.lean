namespace Papyrus

/-- Identifiers for all of the base types of the LLVM (v12) type system. -/
inductive TypeID
-- Primitive types
| /-- 16-bit floating point type -/
  half
| /-- 16-bit floating point type (7-bit significand) -/
  bfloat
| /-- 32-bit floating point type -/
  float
| /-- 64-bit floating point type -/
  double
| /-- 80-bit floating point type (X87) -/
  x86FP80
| /-- 128-bit floating point type (112-bit significand) -/
  fp128
| /-- 128-bit floating point type -/
  ppcFP128
| /-- type with no size -/
  void
| label
| metadata
| /-- MMX vectors (64 bits, X86 specific) -/
  x86MMX
| /-- AMX vectors (8192 bits, X86 specific) -/
  x86AMX
| token
-- Derived types
| /-- Arbitrary bit width integers -/
  integer
| function
| pointer
| struct
| array
| /-- Fixed width SIMD vector type -/
  fixedVector
| /-- Scalable SIMD vector type -/
  scalableVector
deriving Inhabited, BEq, DecidableEq, Repr

attribute [unbox] TypeID
