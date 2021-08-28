import Lean.Parser
import Papyrus.Builders
import Papyrus.Script.Do
import Papyrus.Script.ParserUtil

namespace Papyrus.Script
open Builder Lean Parser Term

@[runParserAttributeHooks]
def llvmModDef := leading_parser
  Parser.ident >> " do " >> modDoSeq

scoped syntax (name := doLlvmModDef)
"llvm " &"module " llvmModDef : doElem

@[macro doLlvmModDef]
def expandDoLlvmModDef : Macro
| `(doElem| llvm module $id:ident do $seq) => do
  let name := identAsStrLit id
  let modDoElems ← expandModDoSeq seq
  let doElems ← modDoElems.mapM expandMacros
  `(doElem| let $id:ident ← module (name := $name) do {$[$doElems:doElem]*})
| _ => Macro.throwUnsupported

scoped syntax (name := cmdLlvmModDef)
declModifiers "llvm " &"module " llvmModDef : command

@[macro cmdLlvmModDef]
def expandCmdLlvmModDef : Macro
| `($mods:declModifiers llvm module $id:ident do $seq) => do
  let name := identAsStrLit id
  let modDoElems ← expandModDoSeq seq
  let doElems ← modDoElems.mapM expandMacros
  `($mods:declModifiers def $id:ident := module (name := $name) do {$[$doElems:doElem]*})
| _ => Macro.throwUnsupported
