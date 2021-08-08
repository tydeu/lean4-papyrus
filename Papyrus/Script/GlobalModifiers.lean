import Lean.Parser
import Papyrus.IR.GlobalRefs

namespace Papyrus.Script
open Lean Parser Term

-- ## Linkage

@[runParserAttributeHooks]
def linkageLit := leading_parser
  nonReservedSymbol "external" <|>
  nonReservedSymbol "available_externally" <|>
  nonReservedSymbol "linkonce" <|>
  nonReservedSymbol "linkonce_odr" <|>
  nonReservedSymbol "weak" <|>
  nonReservedSymbol "weak_odr" <|>
  nonReservedSymbol "appending" <|>
  nonReservedSymbol "internal" <|>
  nonReservedSymbol "private" <|>
  nonReservedSymbol "extern_weak" <|>
  nonReservedSymbol "common"

@[runParserAttributeHooks]
def linkageTerm := leading_parser
  nonReservedSymbol "linkage" >> "(" >> termParser >> ")"

@[runParserAttributeHooks]
def linkage := linkageTerm <|> linkageLit

def expandLinkageLit (stx : Syntax) : (linkage : String) → MacroM Syntax
| "external" => mkCIdent ``Linkage.external
| "available_externally" => mkCIdent ``Linkage.availableExternally
| "linkonce" => mkCIdent ``Linkage.linkOnceAny
| "linkonce_odr" => mkCIdent ``Linkage.linkOnceODR
| "weak" => mkCIdent ``Linkage.weakAny
| "weak_odr" => mkCIdent ``Linkage.weakODR
| "appending" => mkCIdent ``Linkage.appending
| "internal" => mkCIdent ``Linkage.internal
| "private" => mkCIdent ``Linkage.private
| "extern_weak" => mkCIdent ``Linkage.externalWeak
| "common" => mkCIdent ``Linkage.common
| _ => Macro.throwErrorAt stx "unknown linkage"

def expandLinkage : (linkage : Syntax) → MacroM Syntax
| `(linkage| linkage($x:term)) => x
| linkage =>
  match linkage.isLit? ``Script.linkageLit with
  | some val => expandLinkageLit linkage val
  | none => Macro.throwErrorAt linkage "ill-formed linkage"

def expandOptLinkage : (linkage? : Option Syntax) → MacroM Syntax
| some linkage => expandLinkage linkage
| none => mkCIdent ``Linkage.external

-- ## Address Space

@[runParserAttributeHooks]
def addrspace := leading_parser
  nonReservedSymbol "addrspace" >> "(" >> termParser >> ")"

def expandAddrspace : (addrSpace : Syntax) → MacroM Syntax
| `(addrspace| addrspace($x:term)) => x
| stx => Macro.throwErrorAt stx "ill-formed address space"

def expandOptAddrspace : (addrspace? : Option Syntax) → MacroM Syntax
| some addrspace => expandAddrspace addrspace
| none => mkCIdent ``AddressSpace.default
