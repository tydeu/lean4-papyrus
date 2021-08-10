import Lean.Parser
import Papyrus.Script.Util
import Papyrus.Script.IntegerType
import Papyrus.IR.Type

namespace Papyrus.Script

scoped postfix:max "*" => pointerType

open Internal
open Lean Parser

declare_symbol_syntax_cat llvmType
def typeParser (rbp : Nat := 0) := categoryParser `llvmType rbp

macro "type" "(" t:term ")" : llvmType => t

def expandType (stx : Syntax) : MacroM Syntax :=
  expandMacros stx

def expandTypeAsRef (stx : Syntax) : MacroM Syntax := do
  `(← Type.getRef $(← expandType stx))

scoped macro "llvm " _x:&"type " t:llvmType : term => expandType t

--------------------------------------------------------------------------------
-- # Derived Type Parsers
--------------------------------------------------------------------------------

-- ## Function Type

@[runParserAttributeHooks]
def vararg := leading_parser "..."

@[runParserAttributeHooks]
def params := leading_parser
  "(" >> sepBy1 typeParser "," (allowTrailingSep := true) >> Parser.optional vararg >> ")"

def expandParams (stx : Syntax) : MacroM (Array Syntax × Syntax) := do
  (← stx[1].getSepArgs.mapM expandType, (quote !stx[2].isNone))

def expandFunTypeLit (rty : Syntax) (params : Syntax) : MacroM Syntax := do
  let (ptys, vararg) ← expandParams params
  ``(functionType $(← expandType rty) #[$ptys,*] $vararg)

-- ## Pointer Type

@[runParserAttributeHooks]
def addrspace := leading_parser
  nonReservedSymbol "addrspace" true >> "(" >> termParser >> ")"

def expandAddrspace : (addrSpace : Syntax) → MacroM Syntax
| `(addrspace| addrspace($x:term)) => x
| stx => Macro.throwErrorAt stx "ill-formed address space"

def expandOptAddrspace : (addrspace? : Option Syntax) → MacroM Syntax
| some addrspace => expandAddrspace addrspace
| none => mkCIdent ``AddressSpace.default

def expandPtrTypeLit (ty : Syntax) (addrspace? : Option Syntax) : MacroM Syntax := do
  ``(pointerType $(← expandType ty) $(← expandOptAddrspace addrspace?))

-- ## Struct Type

def packedStructTypeLit := leading_parser
  "<{" >> sepBy typeParser "," >> "}>"

def unpackedStructTypeLit := leading_parser
  "{" >> sepBy typeParser "," >> "}"

def structTypeLit :=
  unpackedStructTypeLit <|> packedStructTypeLit

def expandStructTypeLit : (stx : Syntax) → MacroM (Array Syntax × Bool)
| `(unpackedStructTypeLit| { $[$ts:llvmType],* }) => do
  (← ts.mapM expandType, false)
| `(packedStructTypeLit| $x) => do
  (← x[1].getSepArgs.mapM expandType, true)
| stx => Macro.throwErrorAt stx "ill-formed struct llvmType literal"

def expandLiteralStructTypeLit (stx : Syntax) : MacroM Syntax := do
  let (tys, packed) ←  expandStructTypeLit stx
  ``(literalStructType #[$tys,*] $(quote packed))

-- ## Array Type

def xTk := nonReservedSymbol "x" <|> "×"

def arrayTypeLit := leading_parser
  "[" >> termParser maxPrec >> xTk >> typeParser >> "]"

def expandArrayTypeLit : Macro
| `(arrayTypeLit| [$x x $t]) => do ``(arrayType $(← expandType t) $x)
| stx => Macro.throwErrorAt stx "ill-formed array llvmType literal"

-- ## Vector Type

def optVScale :=
  Parser.optional (nonReservedSymbol "vscale" >> xTk)

def vectorTypeLit := leading_parser
 "<" >> optVScale >> termParser maxPrec >> xTk >> typeParser >> ">"

def expandVectorTypeLit : (stx : Syntax) → MacroM Syntax
| `(vectorTypeLit| <$x x $t>) => do
  ``(fixedVectorType $(← expandType t) $x)
| `(vectorTypeLit| <vscale x $x x $t>) => do
  ``(scalableVectorType $(← expandType t) $x)
| stx => Macro.throwErrorAt stx "ill-formed vector llvmType literal"

--------------------------------------------------------------------------------
-- # Type Macros
--------------------------------------------------------------------------------

-- ## Leading Lit Macros

macro t:"half"        : llvmType => mkCIdentFrom t ``halfType
macro t:"bfloat"      : llvmType => mkCIdentFrom t ``bfloatType
macro t:"float"       : llvmType => mkCIdentFrom t ``floatType
macro t:"x86_fp80"    : llvmType => mkCIdentFrom t ``doubleType
macro t:"fp128"       : llvmType => mkCIdentFrom t ``x86FP80Type
macro t:"ppc_fp128"   : llvmType => mkCIdentFrom t ``fp128Type
macro t:"void"        : llvmType => mkCIdentFrom t ``voidType
macro t:"label"       : llvmType => mkCIdentFrom t ``labelType
macro t:"metadata"    : llvmType => mkCIdentFrom t ``metadataType
macro t:"x86_mmx"     : llvmType => mkCIdentFrom t ``x86MMXType
macro t:"x86_amx"     : llvmType => mkCIdentFrom t ``x86AMXType
macro t:"token"       : llvmType => mkCIdentFrom t ``tokenType

macro t:intTypeLit    : llvmType => expandIntTypeLit t
macro t:structTypeLit : llvmType => expandLiteralStructTypeLit t
macro t:arrayTypeLit  : llvmType => expandArrayTypeLit t
macro t:vectorTypeLit : llvmType => expandVectorTypeLit t

-- ## Trailing Lit Macros

macro rt:llvmType ps:params : llvmType => expandFunTypeLit rt ps
macro t:llvmType a?:optional(addrspace) "*" : llvmType => expandPtrTypeLit t a?
