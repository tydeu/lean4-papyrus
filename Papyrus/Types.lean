import Papyrus.Context

namespace Papyrus

--------------------------------------------------------------------------------
-- Type IDs
--------------------------------------------------------------------------------

/-- Identifiers for all of the base types for the LLVM type system. -/
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
| /-- AMX vectors (8192 bits, X86 specific) -/
  X86_AMX
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

--------------------------------------------------------------------------------
-- Basic Types
--------------------------------------------------------------------------------

/-- A reference to the LLVM representation of a Type. -/
constant TypeRef : Type := Unit

namespace TypeRef

@[extern "papyrus_type_get_id"]
constant getTypeID (self : TypeRef) : IO TypeID

@[extern "papyrus_type_get_data"]
constant getTypeData (self : TypeRef) : IO UInt32

@[extern "papyrus_type_get_context"]
constant getContext (self : TypeRef) : IO ContextRef

end TypeRef

--------------------------------------------------------------------------------
-- Primitive Types
--------------------------------------------------------------------------------

@[extern "papyrus_type_get_void"]
constant getVoidType : LLVM TypeRef

@[extern "papyrus_type_get_half"]
constant getHalfType : LLVM TypeRef

@[extern "papyrus_type_get_float"]
constant getFloatType : LLVM TypeRef

@[extern "papyrus_type_get_double"]
constant getDoubleType : LLVM TypeRef
