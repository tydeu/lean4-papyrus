import Lean.Parser
import Papyrus.Script.ParserUtil
import Papyrus.Script.AddressSpace
import Papyrus.Script.IntegerType
import Papyrus.IR.Type

namespace Papyrus.Script

open Lean Syntax Parser

scoped postfix:max "*" => pointerType

--------------------------------------------------------------------------------
-- # Type Category
--------------------------------------------------------------------------------

declare_syntax_cat llvmType (behavior := symbol)
def typeParser (rbp : Nat := 0) := categoryParser `llvmType rbp

macro "type" "(" t:term ")" : llvmType => t
macro (priority := low) t:ident : llvmType => t

def expandType (stx : Syntax) : MacroM Syntax :=
  expandMacros stx

def expandTypeAsRef (stx : Syntax) : MacroM Syntax := do
  `(Type.getRef $(← expandType stx))

def expandTypeAsRefArrow (stx : Syntax) : MacroM Syntax := do
  `(← $(← expandTypeAsRef stx))

scoped macro "llvm " &"type " t:llvmType : term => expandType t

--------------------------------------------------------------------------------
-- # Primitive Types
--------------------------------------------------------------------------------

-- ## Floating Point Types

macro t:"half"        : llvmType => mkCIdentFrom t ``halfType
macro t:"bfloat"      : llvmType => mkCIdentFrom t ``bfloatType
macro t:"float"       : llvmType => mkCIdentFrom t ``floatType
macro t:"double"      : llvmType => mkCIdentFrom t ``doubleType
macro t:"x86_fp80"    : llvmType => mkCIdentFrom t ``x86FP80Type
macro t:"fp128"       : llvmType => mkCIdentFrom t ``fp128Type
macro t:"ppc_fp128"   : llvmType => mkCIdentFrom t ``ppcFP128Type

-- ## Special Types

macro t:"void"        : llvmType => mkCIdentFrom t ``voidType
macro t:"label"       : llvmType => mkCIdentFrom t ``labelType
macro t:"metadata"    : llvmType => mkCIdentFrom t ``metadataType
macro t:"x86_mmx"     : llvmType => mkCIdentFrom t ``x86MMXType
macro t:"x86_amx"     : llvmType => mkCIdentFrom t ``x86AMXType
macro t:"token"       : llvmType => mkCIdentFrom t ``tokenType

--------------------------------------------------------------------------------
-- # Derived Type Parsers
--------------------------------------------------------------------------------

-- ## Integer Types

macro t:intTypeLit : llvmType => expandIntTypeLitAsType t

-- ## Function Types

@[runParserAttributeHooks]
def vararg := leading_parser "..."

@[runParserAttributeHooks]
def params := leading_parser
  "(" >> sepBy typeParser "," (allowTrailingSep := true) >> Parser.optional vararg >> ")"

def expandParams (stx : Syntax) : MacroM (Array Syntax × Syntax) := do
  (← stx[1].getSepArgs.mapM expandType, (quote !stx[2].isNone))

def expandFunTypeLit (rty : Syntax) (params : Syntax) : MacroM Syntax := do
  let (ptys, vararg) ← expandParams params
  mkCAppFrom rty ``functionType #[← expandType rty, quote ptys, vararg]

macro rt:llvmType ps:params : llvmType => expandFunTypeLit rt ps

-- ## Pointer Types

def expandPtrTypeLit (ty : Syntax) (addrspace? : Option Syntax) : MacroM Syntax := do
  mkCAppFrom ty ``pointerType #[← expandType ty, ← expandOptAddrspace addrspace?]

macro t:llvmType a?:optional(addrspace) "*" : llvmType => expandPtrTypeLit t a?

-- ## Struct Types

@[runParserAttributeHooks]
def packedStructTypeLit := leading_parser
  "<{" >> sepBy typeParser "," >> "}>"

@[runParserAttributeHooks]
def unpackedStructTypeLit := leading_parser
  "{" >> sepBy typeParser "," >> "}"

@[runParserAttributeHooks]
def structTypeLit := unpackedStructTypeLit <|> packedStructTypeLit

def expandStructTypeLit : (stx : Syntax) → MacroM (Array Syntax × Bool)
| `(unpackedStructTypeLit| { $[$ts:llvmType],* }) => do
  (← ts.mapM expandType, false)
| `(packedStructTypeLit| $x) => do
  (← x[1].getSepArgs.mapM expandType, true)
| stx => Macro.throwErrorAt stx "ill-formed struct llvmType literal"

def expandLiteralStructTypeLit (stx : Syntax) : MacroM Syntax := do
  let (tys, packed) ← expandStructTypeLit stx
  mkCAppFrom stx ``literalStructType #[quote tys, quote packed]

macro t:structTypeLit : llvmType => expandLiteralStructTypeLit t
macro "%" id:ident : llvmType => mkCAppFrom id ``opaqueStructType #[identAsStrLit id]

-- ## Array Types

def xTk :=
  nonReservedSymbol "x" <|> "×"

@[runParserAttributeHooks]
def arrayTypeLit := leading_parser
  "[" >> termParser maxPrec >> xTk >> typeParser >> "]"

def expandArrayTypeLit : Macro
| stx@`(arrayTypeLit| [$x x $t]) => do
  mkCAppFrom stx ``arrayType #[← expandType t, x]
| stx => Macro.throwErrorAt stx "ill-formed array llvmType literal"

macro t:arrayTypeLit : llvmType => expandArrayTypeLit t

-- ## Vector Types

def optVScale :=
  Parser.optional (nonReservedSymbol "vscale" >> xTk)

@[runParserAttributeHooks]
def vectorTypeLit := leading_parser
 "<" >> optVScale >> termParser maxPrec >> xTk >> typeParser >> ">"

def expandVectorTypeLit : (stx : Syntax) → MacroM Syntax
| stx@`(vectorTypeLit| <$x x $t>) => do
  mkCAppFrom stx ``fixedVectorType #[← expandType t, x]
| stx@`(vectorTypeLit| <vscale x $x x $t>) => do
  mkCAppFrom stx ``scalableVectorType #[← expandType t, x]
| stx => Macro.throwErrorAt stx "ill-formed vector llvmType literal"

macro t:vectorTypeLit : llvmType => expandVectorTypeLit t
