import Lean.Parser
import Papyrus.Builders
import Papyrus.Script.Do
import Papyrus.Script.Type
import Papyrus.Script.ParserUtil
import Papyrus.Script.GlobalModifiers

namespace Papyrus.Script
open Builder Lean Parser Term

def mkFunctionType (ret : Syntax) (params : Array Syntax) (varArg : Syntax) : MacroM Syntax :=
  `(← functionType $ret #[$[$params:term],*] $varArg |>.getRef)

-- ## Function Parameters

@[runParserAttributeHooks]
def paramBinder := leading_parser
   typeParser >> Parser.optional ("%" >> Parser.ident)

@[runParserAttributeHooks]
def paramBinders := leading_parser
  "(" >> sepBy paramBinder "," (allowTrailingSep := true) >> Parser.optional vararg >> ")"

def expandParamBinder : (binder : Syntax) → MacroM (Syntax × Option Syntax)
| `(paramBinder| $ty:llvmType $[ % $arg? ]?) => do (← expandType ty, arg?)
| stx => Macro.throwErrorAt stx "ill-formed function parameter"

def expandParamBinders (binders : Array Syntax)  : MacroM (Array Syntax × Array (Option Syntax)) := do
  Array.unzip <| ← binders.mapM expandParamBinder

-- ## Function Declaration

@[runParserAttributeHooks]
def llvmFunDecl := leading_parser
  Parser.optional linkage >>
  typeParser >> "@" >> Parser.ident >> paramBinders >>
  Parser.optional addrspace

def mkArgNameSetters (fn : Syntax) (args : Array (Option Syntax)) : MacroM (Array Syntax) := do
  let mut stmts := #[]
  for argNo in [0:args.size] do
    if let some arg := args.get! argNo then
      stmts := stmts.push <| ← `(doElem| do
        let x ← FunctionRef.getArg $(quote argNo) $fn:ident
        ValueRef.setName $(identAsStrLit arg) x)
  return stmts


def expandLlvmFunDecl : Macro
| `(llvmFunDecl| $[$linkage?]? $rty:llvmType @ $id:ident ($[$bs:paramBinder],* $[$vararg?:vararg]?) $[$addrspace?:addrspace]?) => do
  let name := identAsStrLit id
  let rtyx ← expandType rty
  let vararg := quote vararg?.isSome
  let (ptys, args) ← expandParamBinders bs
  let type ← mkFunctionType rtyx ptys vararg
  let linkage ← expandOptLinkage linkage?
  let addrspace ← expandOptAddrspace addrspace?
  let stmts ← mkArgNameSetters id args
  `(doElem| do let $id:ident ← declare $type $name $linkage $addrspace; $[$stmts:doElem]*)
| stx => Macro.throwErrorAt stx "ill-formed declare"

macro "declare " d:llvmFunDecl : modDoElem => expandLlvmFunDecl d
scoped macro "llvm " &"declare " d:llvmFunDecl : doElem => expandLlvmFunDecl d

-- ## Function Definition

@[runParserAttributeHooks]
def llvmFunDef := leading_parser
  Parser.optional linkage >>
  typeParser >> "@" >> Parser.ident >> paramBinders >>
  Parser.optional addrspace >>
  " do " >> bbDoSeq

def mkArgLets (args : Array (Option Syntax)) : MacroM (Array Syntax) := do
  let mut argLets := #[]
  for argNo in [0:args.size] do
    if let some arg := args.get! argNo then
      argLets := argLets.push <| ← `(doElem| do
        let $arg:ident ← getArg $(quote argNo)
        ValueRef.setName $(identAsStrLit arg) $arg:ident)
  return argLets

def expandLlvmFunDef : Macro
| `(llvmFunDef| $[$linkage?]? $rty:llvmType @ $id:ident ($[$bs:paramBinder],* $[$vararg?:vararg]?) $[$addrspace?:addrspace]? do $seq) => do
  let name := identAsStrLit id
  let rtyx ← expandType rty
  let vararg := quote vararg?.isSome
  let (ptys, args) ← expandParamBinders bs
  let type ← mkFunctionType rtyx ptys vararg
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
