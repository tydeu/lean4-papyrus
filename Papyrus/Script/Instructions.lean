import Lean.Parser
import Papyrus.Builders
import Papyrus.Script.Do
import Papyrus.Script.Type
import Papyrus.Script.Value
import Papyrus.Script.ParserUtil

namespace Papyrus.Script
open Builder Lean Parser Term

-- ## Instructions

@[runParserAttributeHooks]
def callInst := leading_parser
  nonReservedSymbol "call " true >> Parser.optional typeParser >>
    "@" >> termParser maxPrec >> "(" >> sepBy valueParser ","  >> ")"

def expandCallInst (name : Syntax) : (stx : Syntax) → MacroM Syntax
| `(callInst| call $[$ty?]? @ $fn:term ($[$args],*)) => do
  let argsx ← args.mapM expandValueAsRefArrow
  match ty? with
  | none =>
    ``(call $fn #[$[$argsx],*] $name)
  | some ty =>
    let tyx ← expandTypeAsRefArrow ty
    ``(callAs $tyx $fn #[$[$argsx],*] $name)
| inst => Macro.throwErrorAt inst "ill-formed call instruction"

@[runParserAttributeHooks]
def instruction :=
  callInst

def expandInstruction (name : Syntax) : (inst : Syntax) → MacroM Syntax
| `(instruction| $inst:callInst) => expandCallInst name inst
| inst => Macro.throwErrorAt inst "unknown instruction"

-- ## Named Instructions

@[runParserAttributeHooks]
def namedInst := leading_parser
  "%" >> Parser.ident >> " = " >> instruction

def expandNamedInst : Macro
| `(namedInst| % $id:ident = $inst) => do
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

@[runParserAttributeHooks]
def retVal := nonReservedSymbol "void" true <|> valueParser

def expandRetInst (retVal : Syntax) : MacroM Syntax :=
  if retVal.isOfKind `void then
    `(doElem| retVoid)
  else do
    `(doElem| ret $(← expandValueAsRefArrow retVal))

macro "ret " x:retVal : bbDoElem => expandRetInst x
scoped macro "llvm " &"ret " x:retVal : doElem => expandRetInst x
