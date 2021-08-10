import Lean

namespace Papyrus.Script

open Lean Syntax in
def identAsStrLit (id : Syntax) : Syntax :=
  mkStrLit (info := SourceInfo.fromRef id) <| id.getId.toString (escape := false)

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
def symbolSyntaxCat := leading_parser
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
