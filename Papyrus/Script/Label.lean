import Lean.Parser
import Papyrus.Builders
import Papyrus.Script.Do
import Papyrus.Script.SyntaxUtil

namespace Papyrus.Script

open Lean Parser

@[runParserAttributeHooks]
def label := leading_parser
  ident >> ":" >> bbDoSeq

def expandLabel : (stx : Syntax) → MacroM Syntax
| `(label| $id:ident : $seq) => do
  let name := identAsStrLit id
  let elems ← expandBbDoSeq seq
  `(doElem| let $id:ident ← Builder.label $name (do {$[$elems:doElem]*}))
| stx => Macro.throwErrorAt stx "ill-formed label"

macro (name := bbDoLabel) x:label : bbDoElem => expandLabel x
scoped macro (name := doLabel) "llvm " x:label : doElem => expandLabel x
