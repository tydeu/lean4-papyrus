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
  ``(store $val $ptr $isVolatile $align $order $ssid)
| `(storeInst|
  store $[volatile%$volatile?]? $val:llvmValue, $ptr:llvmValue
    $[, align $align?]?) => do
  let val ← expandValueAsRefArrow val
  let ptr ← expandValueAsRefArrow ptr
  let isVolatile := quote volatile?.isSome
  let align ← expandOptAlign align?
  ``(store $val $ptr $isVolatile $align)
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

--------------------------------------------------------------------------------
-- # Namable Instructions
--------------------------------------------------------------------------------

@[runParserAttributeHooks]
def instruction :=
  loadInst <|>
  getElementPtrInst <|>
  callInst

def expandInstruction (name : Syntax) : (inst : Syntax) → MacroM Syntax
| `(instruction| $inst:loadInst) => expandLoadInst name inst
| `(instruction| $inst:getElementPtrInst) => expandGetElementPtrInst name inst
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

--------------------------------------------------------------------------------
-- # Terminator Instructions
--------------------------------------------------------------------------------

@[runParserAttributeHooks]
def retVal := nonReservedSymbol "void" true <|> valueParser

def expandRetInst (retVal : Syntax) : MacroM Syntax :=
  if retVal.isOfKind `void then
    `(doElem| retVoid)
  else do
    `(doElem| ret $(← expandValueAsRefArrow retVal))

macro "ret " x:retVal : bbDoElem => expandRetInst x
scoped macro "llvm " &"ret " x:retVal : doElem => expandRetInst x
