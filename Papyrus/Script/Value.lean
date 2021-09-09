import Lean.Parser
import Papyrus.Script.Type
import Papyrus.Script.ParserUtil
import Papyrus.Script.AddressSpace
import Papyrus.IR.ConstantRefs
import Papyrus.Builders

namespace Papyrus.Script

open Builder Lean Parser

-- # Category

declare_syntax_cat llvmValue (behavior := symbol)
def valueParser (rbp : Nat := 0) := categoryParser `llvmValue rbp

-- # Expansion

def expandValueAsRef (stx : Syntax) : MacroM Syntax :=
  expandMacros stx

def expandValueAsRefArrow (stx : Syntax) : MacroM Syntax := do
  `(← $(← expandValueAsRef stx))

scoped macro "llvm " x:llvmValue : term => expandValueAsRef x

-- # Special Macros

macro "%" x:ident : llvmValue => x
macro "value" "(" x:term ")" : llvmValue => x
macro (priority := low) x:ident : llvmValue => x

--------------------------------------------------------------------------------
-- # Constants
--------------------------------------------------------------------------------

-- ## Category

declare_syntax_cat llvmConst (behavior := symbol)
def constParser (rbp : Nat := 0) := categoryParser `llvmConst rbp

-- ## Expansion

def expandConstantAsRef (stx : Syntax) : MacroM Syntax :=
  expandMacros stx

def expandConstantAsRefArrow (stx : Syntax) : MacroM Syntax := do
  `(← $(← expandConstantAsRef stx))

macro c:llvmConst : llvmValue => expandConstantAsRef c

-- ## Constant Global String Pointers

macro s:strLit addrspace?:optional(addrspace) "*" : llvmConst  => do
  ``(stringPtr $s $(← expandOptAddrspace addrspace?))

-- ## Integer Constants

@[runParserAttributeHooks]
def constIntLit := leading_parser
  intTypeLit >> (numLit <|> negNumLit)

def expandConstIntLitAsRef : Macro
| `(constIntLit| $t:intTypeLit $n:numLit) => do
  ``(ConstantIntRef.ofNat $(← expandIntTypeLitAsNatLit t) $n)
| `(constIntLit| $t:intTypeLit $n:negNumLit) => do
  ``(ConstantIntRef.ofInt $(← expandIntTypeLitAsNatLit t) $(← expandNegNumLit n))
| stx => Macro.throwErrorAt stx "ill-formed constant int literal"

macro x:constIntLit : llvmConst => expandConstIntLitAsRef x

-- ## Boolean Constants

macro x:"true"  : llvmConst => mkCIdentFrom x ``ConstantIntRef.getTrue
macro x:"false" : llvmConst => mkCIdentFrom x ``ConstantIntRef.getFalse

-- ## Constant Expressions

@[runParserAttributeHooks]
def constPtrToInt := leading_parser
  nonReservedSymbol "ptrtoint " true >>
  "(" >> constParser >> nonReservedSymbol " to " true >> typeParser >> ")"

def expandConstPtrToIntAsRef : Macro
| `(constPtrToInt| ptrtoint ($c:llvmConst to $ty:llvmType)) => do
  let ty ← expandTypeAsRefArrow ty
  let c ← expandConstantAsRefArrow c
  ``(ConstantExprRef.getPtrToInt $c $ty)
| stx => Macro.throwErrorAt stx "ill-formed constant ptrtoint expression"

macro x:constPtrToInt : llvmConst => expandConstPtrToIntAsRef x

@[runParserAttributeHooks]
def constIntToPtr := leading_parser
   nonReservedSymbol "inttoptr " true >>
  "(" >> constParser >> nonReservedSymbol " to " true >> typeParser >> ")"

def expandConstIntToPtrAsRef : Macro
| `(constIntToPtr| inttoptr ($c:llvmConst to $ty:llvmType)) => do
  let ty ← expandTypeAsRefArrow ty
  let c ← expandConstantAsRefArrow c
  ``(ConstantExprRef.getIntToPtr $c $ty)
| stx => Macro.throwErrorAt stx "ill-formed constant inttoptr expression"

macro x:constIntToPtr : llvmConst => expandConstIntToPtrAsRef x
