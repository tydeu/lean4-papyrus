import Lean.Parser

namespace Papyrus.Script

open Lean Parser

-- # Module Do

declare_syntax_cat modDoElem (behavior := symbol)
def modDoElemParser (rbp : Nat := 0) := categoryParser `modDoElem rbp
def modDoSeqItem := leading_parser ppLine >> modDoElemParser >> Parser.optional "; "
def modDoSeqIndent := leading_parser many1Indent modDoSeqItem
def modDoSeqBracketed := leading_parser  "{" >> withoutPosition (many1 modDoSeqItem) >> ppLine >> "}"
def modDoSeq := modDoSeqIndent <|> modDoSeqBracketed

attribute [runParserAttributeHooks]
  modDoElemParser modDoSeqItem modDoSeqItem modDoSeqBracketed modDoSeq

def expandModDoSeq : Syntax → MacroM (Array Syntax)
| `(modDoSeq| { $[$elems:modDoElem]* }) => elems
| `(modDoSeq| $[$elems:modDoElem $[;]?]*) => elems
| stx => Macro.throwErrorAt stx "ill-formed module do sequence"

-- # Basic Block Do

declare_syntax_cat bbDoElem (behavior := symbol)
def bbDoElemParser (rbp : Nat := 0) := categoryParser `bbDoElem rbp
def bbDoSeqItem := leading_parser ppLine >> bbDoElemParser >> Parser.optional "; "
def bbDoSeqIndent := leading_parser many1Indent bbDoSeqItem
def bbDoSeqBracketed := leading_parser  "{" >> withoutPosition (many1 bbDoSeqItem) >> ppLine >> "}"
def bbDoSeq := bbDoSeqIndent <|> bbDoSeqBracketed

attribute [runParserAttributeHooks]
  bbDoElemParser bbDoSeqItem bbDoSeqIndent bbDoSeqBracketed bbDoSeq

def expandBbDoSeq : Syntax → MacroM (Array Syntax)
| `(bbDoSeq| { $[$elems:bbDoElem]* }) => elems
| `(bbDoSeq| $[$elems:bbDoElem $[;]?]*) => elems
| stx => Macro.throwErrorAt stx "ill-formed basic block do sequence"

-- # Nesting Lean Do Elements

macro (priority := low) x:doElem : modDoElem => x
macro (priority := low) x:doElem : bbDoElem => x
