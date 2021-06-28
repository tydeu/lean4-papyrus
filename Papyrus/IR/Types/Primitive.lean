import Lean.Parser
import Papyrus.IR.TypeRefs

namespace Papyrus

open Lean Parser Command in set_option hygiene false in
/-- Macro for creating singleton Lean types for primitive LLVM types. -/
scoped macro (name := externSingletonTypeDecl) doc:docComment
"extern_singleton_type" typ:ident singl:ident : command => do
  let getGlobalRef := mkIdentFrom typ <|
    typ.getId.modifyBase fun name => s!"get{name.getRoot}Ref"
  let getRef := mkIdentFrom typ <| typ.getId.modifyBase (. ++ `getRef)
  `(
    $doc:docComment
    structure $typ deriving Inhabited

    $doc:docComment
    def $singl : $typ := arbitrary

    /-- Get a reference to the LLVM representation of this type. -/
    def $getRef (_self : $typ) := $getGlobalRef

    instance : ToTypeRef $typ := ⟨$getRef⟩
  )

-- # Special Types

/-- An empty type. -/
extern_singleton_type VoidType voidType

/-- A label type. -/
extern_singleton_type LabelType labelType

/-- A metadata type. -/
extern_singleton_type MetadataType metadataType

/-- A token type. -/
extern_singleton_type TokenType tokenType

/-- A 64-bit X86 MMX vector type. -/
extern_singleton_type X86MMXType x86MMXType

/-- A 8192-bit X86 AMX vector type. -/
extern_singleton_type X86AMXType x86AMXType

-- # Floating Point Types

/-- A 16-bit floating point type. -/
extern_singleton_type HalfType halfType

/-- A 16-bit (7-bit significand) floating point type. -/
extern_singleton_type BFloatType bfloatType

/-- A 32-bit floating point type. -/
extern_singleton_type FloatType floatType

/-- A 64-bit floating point type. -/
extern_singleton_type DoubleType doubleType

/-- An X87 80-bit floating point type. -/
extern_singleton_type X86FP80Type x86FP80Type

/-- A 128-bit (112-bit significand) floating point type. -/
extern_singleton_type FP128Type fp128Type

/-- A PowerPC 128-bit floating point type. -/
extern_singleton_type PPCFP128Type ppcFP128Type
