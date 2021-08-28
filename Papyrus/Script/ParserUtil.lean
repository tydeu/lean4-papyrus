import Lean.Parser
import Papyrus.Script.SyntaxUtil

open Lean Parser
namespace Papyrus.Script

@[runParserAttributeHooks]
def negNumLit := leading_parser
  symbol "-" >> checkNoWsBefore >> numLit

def expandNegNumLit : (stx : Syntax) → MacroM Syntax
| `(negNumLit | -$n:numLit) => ``(-$n)
| stx => Macro.throwErrorAt stx "ill-formed negative numeric literal"
