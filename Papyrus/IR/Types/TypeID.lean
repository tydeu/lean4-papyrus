namespace Papyrus

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
