import Lean.Parser
import Papyrus.Builders
import Papyrus.Script.Do
import Papyrus.Script.Type
import Papyrus.Script.Value
import Papyrus.Script.ParserUtil

namespace Papyrus.Script
open Builder Lean Parser Term

@[runParserAttributeHooks]
def syncscope :=
  nonReservedSymbol "syncscope " true >> "(" >> termParser >> ")"

@[runParserAttributeHooks]
def optSyncScope :=
  Parser.optional (nonReservedSymbol "syncscope " true >> "(" >> termParser >> ")")

@[runParserAttributeHooks]
def atomicOrderingLit := leading_parser
  nonReservedSymbol "unordered" true <|>
  nonReservedSymbol "monotonic" true <|>
  nonReservedSymbol "acquire" true <|>
  nonReservedSymbol "release" true <|>
  nonReservedSymbol "acq_rel" true <|>
  nonReservedSymbol "seq_cst" true

@[runParserAttributeHooks]
def atomicOrderingTerm := leading_parser
  nonReservedSymbol "ordering" true >> "(" >> termParser >> ")"

@[runParserAttributeHooks]
def atomicOrdering := atomicOrderingTerm <|> atomicOrderingLit

def expandAtomicOrderingLit (stx : Syntax) : (lit : String) → MacroM Syntax
| "unordered" => mkCIdentFrom stx ``AtomicOrdering.unordered
| "monotonic" => mkCIdentFrom stx ``AtomicOrdering.monotonic
| "acquire" => mkCIdentFrom stx ``AtomicOrdering.acquire
| "release" => mkCIdentFrom stx ``AtomicOrdering.release
| "acq_rel" => mkCIdentFrom stx ``AtomicOrdering.acquireRelease
| "seq_cst" => mkCIdentFrom stx ``AtomicOrdering.sequentiallyConsistent
| _ => Macro.throwErrorAt stx "unknown atomic ordering"

def expandAtomicOrdering : (order : Syntax) → MacroM Syntax
| `(atomicOrdering| ordering($x:term)) => x
| linkage =>
  match linkage.isLit? ``atomicOrderingLit with
  | some val => expandAtomicOrderingLit linkage val
  | none => Macro.throwErrorAt linkage "ill-formed atomic ordering"

-- TODO: convert string scopes (e.g., `"singlethread"`) to IDs
def expandOptSyncScope (ssid? : Option Syntax) : MacroM Syntax :=
  ssid?.getD (mkCIdent ``SyncScopeID.system)

-- TODO: default `align` to ABI align of module when not provided
def expandOptAlign (align? : Option Syntax) : MacroM Syntax :=
  align?.getD (quote 1)

--------------------------------------------------------------------------------
-- # Instructions
--------------------------------------------------------------------------------

-- ## `ret`

def voidTk := leading_parser
  nonReservedSymbol "void" true

@[runParserAttributeHooks]
def retInst := leading_parser
   nonReservedSymbol "ret " true >>
   (voidTk <|> valueParser)

def expandRetInst : (stx : Syntax) → MacroM Syntax
| `(retInst| ret void) => `(doElem| retVoid)
| `(retInst| ret $v:llvmValue) => do `(doElem| ret $(← expandValueAsRefArrow v))
| stx => Macro.throwErrorAt stx "ill-formed ret instruction"

macro x:retInst : bbDoElem => expandRetInst x
scoped macro "llvm " x:retInst : doElem => expandRetInst x

-- ## `br`

@[runParserAttributeHooks]
def brInst := leading_parser
  nonReservedSymbol "br " true >>
  valueParser >> Parser.optional (", " >> valueParser >> ", " >> valueParser)

def expandBrInst : (stx : Syntax) → MacroM Syntax
| `(brInst| br $cond, $ifTrue, $ifFalse) => do
  let cond ← expandValueAsRefArrow cond
  let ifTrue ← expandValueAsRefArrow ifTrue
  let ifFalse ← expandValueAsRefArrow ifFalse
  `(doElem| condBr $cond $ifTrue $ifFalse)
| `(brInst| br $bb) => do `(doElem| br $(← expandValueAsRefArrow bb))
| stx => Macro.throwErrorAt stx "ill-formed br instruction"

macro x:brInst : bbDoElem => expandBrInst x
scoped macro "llvm " x:brInst : doElem => expandBrInst x

-- ## `load`

@[runParserAttributeHooks]
def loadNotAtomicInst := leading_parser
  Parser.optional (nonReservedSymbol "volatile " true) >>
  typeParser >> ", " >> valueParser >>
  Parser.optional (", " >> nonReservedSymbol "align " true >> termParser)

@[runParserAttributeHooks]
def loadAtomicInst := leading_parser
  nonReservedSymbol "atomic " true >>
  Parser.optional (nonReservedSymbol "volatile " true) >>
  typeParser >> ", " >> valueParser >>
  Parser.optional (syncscope >> ppSpace) >> atomicOrdering >>
  ", " >> nonReservedSymbol "align " true >> termParser

@[runParserAttributeHooks]
def loadInst := leading_parser
  nonReservedSymbol "load " true >>
  (loadAtomicInst <|> loadNotAtomicInst)

def expandLoadInst (name : Syntax) : (stx : Syntax) → MacroM Syntax
| `(loadInst|
  load atomic $[volatile%$volatile?]?  $ty:llvmType, $ptr:llvmValue
    $[syncscope($ssid?)]? $order, align $align) => do
  let ty ← expandTypeAsRefArrow ty
  let ptr ← expandValueAsRefArrow ptr
  let isVolatile := quote volatile?.isSome
  let order ← expandAtomicOrdering order
  let ssid ← expandOptSyncScope ssid?
  ``(load $ty $ptr $name $isVolatile $align $order $ssid)
| `(loadInst|
  load $[volatile%$volatile?]? $ty:llvmType, $ptr:llvmValue
    $[, align $align?]?) => do
  let ty ← expandTypeAsRefArrow ty
  let ptr ← expandValueAsRefArrow ptr
  let isVolatile := quote volatile?.isSome
  let align ← expandOptAlign align?
  ``(load $ty $ptr $name $isVolatile $align)
| inst => Macro.throwErrorAt inst "ill-formed load instruction"

-- ## `store`

@[runParserAttributeHooks]
def storeNotAtomicInst := leading_parser
  Parser.optional (nonReservedSymbol "volatile " true) >>
  valueParser >> ", " >> valueParser >>
  Parser.optional (", " >> nonReservedSymbol "align " true >> termParser)

@[runParserAttributeHooks]
def storeAtomicInst := leading_parser
  nonReservedSymbol "atomic " true >>
  Parser.optional (nonReservedSymbol "volatile " true) >>
  valueParser >> ", " >> valueParser >>
  Parser.optional (syncscope >> ppSpace) >> atomicOrdering >>
  ", " >> nonReservedSymbol "align " true >> termParser

@[runParserAttributeHooks]
def storeInst := leading_parser
  nonReservedSymbol "store " true >>
  (storeAtomicInst <|> storeNotAtomicInst)

def expandStoreInst : (stx : Syntax) → MacroM Syntax
| `(storeInst|
  store atomic $[volatile%$volatile?]?  $val:llvmValue, $ptr:llvmValue
    $[syncscope($ssid?)]? $order, align $align) => do
  let val ← expandValueAsRefArrow val
  let ptr ← expandValueAsRefArrow ptr
  let isVolatile := quote volatile?.isSome
  let order ← expandAtomicOrdering order
  let ssid ← expandOptSyncScope ssid?
  `(doElem| store $val $ptr $isVolatile $align $order $ssid)
| `(storeInst|
  store $[volatile%$volatile?]? $val:llvmValue, $ptr:llvmValue
    $[, align $align?]?) => do
  let val ← expandValueAsRefArrow val
  let ptr ← expandValueAsRefArrow ptr
  let isVolatile := quote volatile?.isSome
  let align ← expandOptAlign align?
  `(doElem| store $val $ptr $isVolatile $align)
| inst => Macro.throwErrorAt inst "ill-formed store instruction"

macro x:storeInst : bbDoElem => expandStoreInst x
scoped macro "llvm " x:storeInst : doElem => expandStoreInst x

-- ## `getelementptr`

@[runParserAttributeHooks]
def getElementPtrInst := leading_parser
  nonReservedSymbol "getelementptr " true >>  Parser.optional (nonReservedSymbol "inbounds " true) >>
    typeParser >> "," >> valueParser >> "," >> sepBy valueParser ","

def expandGetElementPtrInst (name : Syntax) : (stx : Syntax) → MacroM Syntax
| `(getElementPtrInst| getelementptr $[inbounds%$inbounds?]? $ty:llvmType, $ptr:llvmValue, $[$idxs:llvmValue],*) => do
  let tyx ← expandTypeAsRefArrow ty
  let ptrx ← expandValueAsRefArrow ptr
  let idxsx ← idxs.mapM expandValueAsRefArrow
  match inbounds? with
  | none => ``(getElementPtr $tyx $ptrx #[$[$idxsx],*] $name)
  | some _ => ``(getElementPtrInbounds $tyx $ptrx #[$[$idxsx],*] $name)
| inst => Macro.throwErrorAt inst "ill-formed getelementptr instruction"

-- ## `call`

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

-- ## `phi`
@[runParserAttributeHooks]
def phiNodeFields := leading_parser
  "[" >>  valueParser >> "," >> valueParser >> "]" 

@[runParserAttributeHooks]
def phiNode := leading_parser
  nonReservedSymbol "phi " true >> typeParser >> sepBy phiNodeFields ","

def expandPhiNode (name : Syntax) : (stx : Syntax) → MacroM Syntax
| `(phiNode| phi $ty $fields:phiNodeFields,*) => do
  let fieldsx ← fields.getElems.mapM fun stx => do
    let vx ← expandValueAsRefArrow stx[1]
    let bbx ← expandValueAsRefArrow stx[3]
    ``(($vx,$bbx))
  let tyx ← expandTypeAsRefArrow ty
  ``(phi $tyx #[$[$fieldsx],*] $name)
| inst => Macro.throwErrorAt inst "ill-formed Phi instruction"


--------------------------------------------------------------------------------
-- # Namable Instructions
--------------------------------------------------------------------------------

@[runParserAttributeHooks]
def instruction :=
  loadInst <|>
  getElementPtrInst <|>
  callInst <|>
  phiNode

def expandInstruction (name : Syntax) : (inst : Syntax) → MacroM Syntax
| `(instruction| $inst:loadInst) => expandLoadInst name inst
| `(instruction| $inst:getElementPtrInst) => expandGetElementPtrInst name inst
| `(instruction| $inst:callInst) => expandCallInst name inst
| `(instruction| $inst:phiNode) => expandPhiNode name inst
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
