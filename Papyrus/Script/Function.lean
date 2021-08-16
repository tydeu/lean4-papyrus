import Lean.Parser
import Papyrus.Builders
import Papyrus.Script.Do
import Papyrus.Script.Util
import Papyrus.Script.Type
import Papyrus.Script.GlobalModifiers

namespace Papyrus.Script
open Builder Lean Parser Term

def mkFunctionType (ret : Syntax) (params : Array Syntax) (varArg : Syntax) : MacroM Syntax :=
  `(← functionType $ret #[$[$params:term],*] $varArg |>.getRef)

-- ## Function Parameters

@[runParserAttributeHooks]
def paramBinder := leading_parser
  Parser.ident >> " : " >> typeParser

@[runParserAttributeHooks]
def paramBinders := leading_parser
  "(" >> sepBy paramBinder "," (allowTrailingSep := true) >> Parser.optional vararg >> ")"

def expandParamBinder (binder : Syntax) : MacroM (Syntax × Syntax) := do
  (binder[0], ← expandType binder[2])

def expandParamBinders (binders : Array Syntax)  : MacroM (Array Syntax × Array Syntax) := do
  Array.unzip <| ← binders.mapM expandParamBinder

-- ## Function Declaration

@[runParserAttributeHooks]
def llvmFunDecl := leading_parser
  Parser.optional linkage >>
  typeParser >>  Parser.ident >> params >>
  Parser.optional addrspace

def expandLlvmFunDecl : Macro
| `(llvmFunDecl| $[$linkage?]? $rty:llvmType $id:ident $ps:params $[$addrspace?:addrspace]?) => do
  let name := identAsStrLit id
  let rtyx ← expandType rty
  let (ptys, vararg) ← expandParams ps
  let type ← mkFunctionType rtyx ptys vararg
  let linkage ← expandOptLinkage linkage?
  let addrspace ← expandOptAddrspace addrspace?
  `(doElem| let $id:ident ← declare $type $name $linkage $addrspace)
| stx => Macro.throwErrorAt stx "ill-formed declare"

macro "declare " d:llvmFunDecl : modDoElem => expandLlvmFunDecl d
scoped macro "llvm " &"declare " d:llvmFunDecl : doElem => expandLlvmFunDecl d

-- ## Function Definition

@[runParserAttributeHooks]
def llvmFunDef := leading_parser
  Parser.optional linkage >>
  typeParser >> Parser.ident >> paramBinders >>
  Parser.optional addrspace >>
  " do " >> bbDoSeq

def mkArgLets (args : Array Syntax) : MacroM (Array Syntax) := do
  let mut argLets := #[]
  for argNo in [0:args.size] do
    let arg := args.get! argNo
    let argLet ← `(doElem| let $arg:ident ← getArg $(quote argNo))
    argLets := Array.push argLets argLet
  return argLets

def expandLlvmFunDef : Macro
| `(llvmFunDef| $[$linkage?]? $rty:llvmType $id:ident ($[$bs:paramBinder],* $[$vararg?:vararg]?) $[$addrspace?:addrspace]? do $seq) => do
  let name := identAsStrLit id
  let rtyx ← expandType rty
  let vararg := quote vararg?.isSome
  let (args, params) ← expandParamBinders bs
  let type ← mkFunctionType rtyx params vararg
  let linkage ← expandOptLinkage linkage?
  let addrspace ← expandOptAddrspace addrspace?
  let bbDoElems ← expandBbDoSeq seq
  let doElems ← bbDoElems.mapM expandMacros
  let argLets ← mkArgLets args
  let stmts := argLets ++ doElems
  `(doElem| let $id:ident ← define $type (do {$[$stmts:doElem]*}) $name $linkage $addrspace)
| stx => Macro.throwErrorAt stx "ill-formed define"

macro "define " d:llvmFunDef : modDoElem => expandLlvmFunDef d
scoped macro  "llvm " &"define " d:llvmFunDef : doElem => expandLlvmFunDef d
