import Lean

namespace Papyrus.Script

namespace Internal
open Lean Elab Command

-- Taken from the Lean Core
def declareSyntaxCatQuotParser (catName : Name) : CommandElabM Unit := do
  if let Name.str _ suffix _ := catName then
    let quotSymbol := "`(" ++ suffix ++ "|"
    let name := catName ++ `quot
    let kind := ``Lean.Parser.Term.quot
    let cmd ← `(
      @[termParser] def $(mkIdent name) : Lean.ParserDescr :=
        Lean.ParserDescr.node $(quote kind) $(quote Lean.Parser.maxPrec)
          (Lean.ParserDescr.binary `andthen (Lean.ParserDescr.symbol $(quote quotSymbol))
            (Lean.ParserDescr.binary `andthen
              (Lean.ParserDescr.unary `incQuotDepth (Lean.ParserDescr.cat $(quote catName) 0))
              (Lean.ParserDescr.symbol ")"))))
    elabCommand cmd

@[scoped commandParser]
def symbolSyntaxCat  := leading_parser
  "declare_symbol_syntax_cat " >> Parser.ident

@[commandElab symbolSyntaxCat] def elabDeclareSymbolSyntaxCat : CommandElab := fun stx => do
  let catName  := stx[1].getId
  let attrName := catName.appendAfter "Parser"
  let env ← getEnv
  let env ← liftIO $ Parser.registerParserCategory env attrName catName
    Parser.LeadingIdentBehavior.symbol
  setEnv env
  declareSyntaxCatQuotParser catName

end Internal
open Internal

open Lean Parser

-- # Module Do

declare_symbol_syntax_cat modDoElem
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

declare_symbol_syntax_cat bbDoElem
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
