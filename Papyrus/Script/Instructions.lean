import Lean.Parser
import Papyrus.IR.Types
import Papyrus.Builders
import Papyrus.Script.Do
import Papyrus.Script.Util

namespace Papyrus.Script
open Builder Lean Parser Term

-- ## Instructions

@[runParserAttributeHooks]
def callInst := leading_parser
  nonReservedSymbol "call " >> Parser.optional ("(" >> termParser >> ")") >>
    termParser maxPrec >> "(" >> sepBy termParser ","  >> ")"

@[runParserAttributeHooks]
def instruction :=
  callInst

def expandInstruction (name : Syntax) : (inst : Syntax) → MacroM Syntax
| `(instruction| call $[($ty?)]? $fn:term ($[$args],*)) =>
  match ty? with
  | none => `(call $fn #[$[$args],*] $name)
  | some ty => `(callAs $ty $fn #[$[$args],*] $name)
| inst => Macro.throwErrorAt inst "unknown instruction"

-- ## Named Instructions

@[runParserAttributeHooks]
def namedInst := leading_parser
  "%" >> Parser.ident >> " := " >> instruction

def expandNamedInst : Macro
| `(namedInst| % $id:ident := $inst) => do
  let name := identAsStrLit id
  let inst ← expandInstruction name inst
  `(doElem| let $id:ident ← $inst:term)
| stx => Macro.throwErrorAt stx "ill-formed named instruction"

macro inst:namedInst : bbDoElem => expandNamedInst inst
scoped macro "llvm " inst:namedInst : doElem => expandNamedInst inst

-- ## Unnamed Instructions

def expandUnnamedInst (inst : Syntax) : MacroM  Syntax := do
  let name := Syntax.mkStrLit ""
  let inst ← expandInstruction name inst
  `(doElem| let a ← $inst:term)

macro inst:instruction : bbDoElem => expandUnnamedInst inst
scoped macro "llvm " inst:instruction : doElem => expandUnnamedInst inst

-- ## Void Instructions

def expandLlvmRet : (retVal? : Option Syntax) → MacroM Syntax
| none => `(doElem| retVoid)
| some x => `(doElem| ret $x)

syntax (name := bbDoLlvmRet) "ret " optional(term) : bbDoElem

@[macro bbDoLlvmRet]
def expandBbDoLLvmRet : Macro
| `(bbDoElem| ret $[$x?]?) => expandLlvmRet x?
| _ => Macro.throwUnsupported

scoped syntax (name := doLlvmRet) "llvm " &"ret " optional(term) : doElem

@[macro doLlvmRet]
def expandDoLLvmRet : Macro
| `(doElem| llvm ret $[$x?]?) => expandLlvmRet x?
| _ => Macro.throwUnsupported
