import Lean.Parser
import Papyrus.Types.TypeRef

namespace Papyrus

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
