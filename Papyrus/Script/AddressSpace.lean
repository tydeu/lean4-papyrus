import Lean.Parser
import Papyrus.IR.AddressSpace

namespace Papyrus.Script

open Lean Parser

@[runParserAttributeHooks]
def addrspace := leading_parser
  nonReservedSymbol "addrspace" true >> "(" >> termParser >> ")"

def expandAddrspace : (addrSpace : Syntax) → MacroM Syntax
| `(addrspace| addrspace($x:term)) => x
| stx => Macro.throwErrorAt stx "ill-formed address space"

def expandOptAddrspace : (addrspace? : Option Syntax) → MacroM Syntax
| some addrspace => expandAddrspace addrspace
| none => mkCIdent ``AddressSpace.default
