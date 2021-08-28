import Lean.Parser
import Papyrus.Script.SyntaxCat
import Papyrus.Script.ParserUtil
import Papyrus.Script.IntegerType
import Papyrus.IR.ConstantRefs
import Papyrus.Builders

namespace Papyrus.Script

open Internal
open Builder Lean Parser

-- # Category

declare_symbol_syntax_cat llvmValue
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

-- # Integer Constants

@[runParserAttributeHooks]
def constIntLit := leading_parser
  intTypeLit >> (numLit <|> negNumLit)

def expandConstIntLitAsRef : Macro
| `(constIntLit| $t:intTypeLit $n:numLit) => do
  ``(ConstantIntRef.ofNat $(← expandIntTypeLitAsNatLit t) $n)
| `(constIntLit| $t:intTypeLit $n:negNumLit) => do
  ``(ConstantIntRef.ofInt $(← expandIntTypeLitAsNatLit t) $(← expandNegNumLit n))
| stx => Macro.throwErrorAt stx "ill-formed constant int literal"

macro x:constIntLit : llvmValue => expandConstIntLitAsRef x

-- # Boolean Constants

macro x:"true"  : llvmValue => mkCIdentFrom x ``ConstantIntRef.getTrue
macro x:"false" : llvmValue => mkCIdentFrom x ``ConstantIntRef.getFalse

-- # String Pointers

macro s:strLit "*" : llvmValue => do
  ``(stringPtr $s)
